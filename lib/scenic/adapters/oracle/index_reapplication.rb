# frozen_string_literal: true

module Scenic
  module Adapters
    class Oracle
      class IndexReapplication
        def initialize(connection:, speaker: ActiveRecord::Migration)
          @connection = connection
          @speaker = speaker
        end

        def on(name)
          indexes = Indexes.new(connection: connection).on(name)

          yield

          indexes.each(&method(:try_index_create))
        end

        private

        attr_reader :connection, :speaker

        def try_index_create(index)
          if valid_index?(index)
            if connection.execute(index.definition)
              say "index '#{index.index_name}' on '#{index.object_name}' has been recreated"
            end
          else
            say "index '#{index.index_name}' on '#{index.object_name}' is no longer valid and has been dropped."
          end
        end

        def valid_index?(index)
          object_columns = Set.new(object_columns(index.object_name))
          index_columns = Set.new(index.columns)

          index_columns.subset?(object_columns)
        end

        def object_columns(name)
          connection.select_values(<<-EOSQL)
            select lower(column_name)
            from user_tab_cols
            where table_name = '#{name}'
          EOSQL
        end

        def say(message)
          subitem = true
          speaker.say(message, subitem)
        end
      end
    end
  end
end
