# frozen_string_literal: true

require_relative "oracle/index_reapplication"
require_relative "oracle/indexes"
require_relative "oracle/refresh_dependencies"

module Scenic
  module Adapters
    class Oracle
      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      def views
        all_views + all_mviews
      end

      def create_view(name, definition)
        execute("create view #{quote_table_name(name)} as #{definition}")
      end

      def drop_view(name)
        execute("drop view #{quote_table_name(name)}")
      end

      def replace_view(name, definition)
        execute("create or replace view #{quote_table_name(name)} as #{definition}")
      end

      def update_view(name, definition)
        drop_view(name)
        create_view(name, definition)
      end

      def create_materialized_view(name, definition, no_data: false)
        execute("create materialized view #{quote_table_name(name)} #{'build deferred' if no_data} as #{definition}")
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

      def all_views
        select_all("select lower(view_name) name, text definition from user_views").map do |view|
          Scenic::View.new(name: view["name"], definition: view["definition"], materialized: false)
        end
      end

      def all_mviews
        select_all("select lower(mview_name) as name, query as definition from user_mviews").map do |view|
          Scenic::View.new(name: view["name"], definition: view["definition"], materialized: true)
        end
      end

      def refresh_dependencies_for(name)
        Scenic::Adapters::Oracle::RefreshDependencies.call(name, self, connection)
      end
    end
  end
end
