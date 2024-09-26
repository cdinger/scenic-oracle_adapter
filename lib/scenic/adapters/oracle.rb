# frozen_string_literal: true

require_relative "oracle/index_reapplication"
require_relative "oracle/indexes"
require_relative "oracle/refresh_dependencies"
require_relative "oracle/view"
require "active_support/core_ext/string/strip"
require "tsortable_hash"

module Scenic
  module Adapters
    class Oracle
      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      def views
        sorted_dependency_views + sorted_missing_dependency_views
      end

      def create_view(name, definition)
        execute("create view #{quote_table_name(name)} as #{trimmed_definition(definition)}")
      end

      def drop_view(name)
        execute("drop view #{quote_table_name(name)}")
      end

      def replace_view(name, definition)
        execute("create or replace view #{quote_table_name(name)} as #{trimmed_definition(definition)}")
      end

      def update_view(name, definition)
        drop_view(name)
        create_view(name, definition)
      end

      def create_materialized_view(name, definition, no_data: false)
        execute("create materialized view #{quote_table_name(name)} #{'build deferred' if no_data} as #{trimmed_definition(definition)}")
      end

      def update_materialized_view(name, definition, no_data: false)
        IndexReapplication.new(connection: connection).on(name) do
          drop_materialized_view(name)
          create_materialized_view(name, definition, no_data: no_data)
        end
      end

      def drop_materialized_view(name)
        execute("drop materialized view #{quote_table_name(name)}")
      end

      def refresh_materialized_view(name, concurrently: false, cascade: false)
        refresh_dependencies_for(name) if cascade

        atomic_refresh = concurrently.to_s.upcase
        execute(<<~EOSQL)
          begin
            dbms_mview.refresh('#{name}', method => '?', atomic_refresh => #{atomic_refresh});
          end;
        EOSQL
      end

      def populated?(name)
        !select_value("select last_refresh_date from user_mviews where mview_name = '#{name.upcase}'").nil?
      end

      delegate :connection, to: :@connectable
      delegate :select_all, :select_value, :execute, :quote_table_name, to: :connection

      private

      def view_dependencies
        @view_dependencies ||= select_all(<<~EOSQL)
          select lower(uo.object_name) as name, lower(ud.referenced_name) as dependency
          from user_objects uo
            left join user_dependencies ud on
              uo.object_name = ud.name
              and (
                (ud.referenced_type in ('VIEW', 'MATERIALIZED VIEW'))
                OR
                (
                  ud.referenced_type IN ('TABLE')
                  AND
                  ud.referenced_name in (select mview_name from user_mviews)
                )
              )
              and ud.referenced_name in (select object_name from user_objects)
              and ud.referenced_owner = user
          where uo.object_type in ('VIEW', 'MATERIALIZED VIEW')
          order by lower(uo.object_name), lower(ud.referenced_name)
        EOSQL
      end

      def dependency_order
        views_hash = TSortableHash.new

        view_dependencies.each do |view_data|
          views_hash[view_data["name"]] ||= []
          views_hash[view_data["name"]] << view_data["dependency"] unless view_data["dependency"].nil?
        end

        views_hash.tsort
      end

      def sorted_dependency_views
        all_view_objects.filter do |view|
          dependency_order.include?(view.name)
        end.sort_by do |view|
          dependency_order.index(view.name)
        end
      end

      def sorted_missing_dependency_views
        all_view_objects.filter do |view|
          dependency_order.exclude?(view.name)
        end.sort_by do |view|
          view.name
        end
      end

      def all_views
        select_all("select lower(view_name) name, text definition from user_views").map do |view|
          Scenic::Adapters::Oracle::View.new(name: view["name"], definition: view["definition"], materialized: false)
        end
      end

      def all_mviews
        select_all("select lower(mview_name) as name, query as definition from user_mviews").map do |view|
          Scenic::Adapters::Oracle::View.new(name: view["name"], definition: view["definition"], materialized: true)
        end
      end

      def all_view_objects
        all_views + all_mviews
      end

      def refresh_dependencies_for(name)
        Scenic::Adapters::Oracle::RefreshDependencies.call(name, self, connection)
      end

      def trimmed_definition(sql)
        sql.rstrip.sub(/;$/, "").rstrip.strip_heredoc
      end
    end
  end
end
