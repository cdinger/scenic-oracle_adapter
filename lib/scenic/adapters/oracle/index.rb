# frozen_string_literal: true

module Scenic
  module Adapters
    class Oracle
      class Index < Scenic::Index
        attr_reader :columns

        def initialize(object_name:, index_name:, columns:, definition:)
          @object_name = object_name
          @index_name = index_name
          @columns = columns
          @definition = definition
        end
      end
    end
  end
end
