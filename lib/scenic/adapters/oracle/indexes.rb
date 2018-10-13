# frozen_string_literal: true

require_relative "index"

module Scenic
  module Adapters
    class Oracle
      class Indexes
        def initialize(connection:)
          @connection = connection
        end

        def on(name)
          indexes_on(name).map(&method(:index_from_database))
        end

        private

        attr_reader :connection
        delegate :quote_table_name, to: :connection

        def indexes_on(name)
          connection.select_all(<<-EOSQL)
            select
              table_name as object_name,
              index_name,
              dbms_metadata.get_ddl('INDEX', index_name, table_owner) as definition
            from user_indexes
            where table_name = upper('#{name}')
          EOSQL
        end

        def index_columns(index_name)
          connection.select_values(<<-EOSQL)
            select lower(column_name)
            from user_ind_columns
            where index_name = upper('#{index_name}')
            order by column_position
          EOSQL
        end

        def index_from_database(result)
          Scenic::Adapters::Oracle::Index.new(
            object_name: result["object_name"],
            index_name: result["index_name"],
            columns: index_columns(result["index_name"]),
            definition: result["definition"]
          )
        end
      end
    end
  end
end
