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

      def create_materialized_view(name, definition)
        execute("create materialized view #{quote_table_name(name)} as #{definition}")
      end

      def update_materialized_view(name, definition)
        drop_materialized_view(name)
        create_materialized_view(name, definition)
      end

      def drop_materialized_view(name)
        execute("drop materialized view #{quote_table_name(name)}")
      end

      delegate :connection, to: :@connectable
      delegate :select_all, :execute, :quote_table_name, to: :connection

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

    end
  end
end
