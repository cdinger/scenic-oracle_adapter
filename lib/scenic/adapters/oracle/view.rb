# frozen_string_literal: true

require "scenic/view"

module Scenic
  module Adapters
    class Oracle
      class View < Scenic::View
        attr_reader :no_data

        def initialize(name:, definition:, materialized:, no_data: false)
          super(name: name, definition: definition, materialized: materialized)
          @no_data = no_data
        end

        def to_schema
          materialized_option = if materialized
            if no_data
              "materialized: { no_data: true } , "
            else
              "materialized: true, "
            end
          else
            ""
          end

          <<-DEFINITION
  create_view #{UnaffixedName.for(name).inspect}, #{materialized_option}sql_definition: <<-\SQL
    #{escaped_definition.indent(2)}
  SQL
          DEFINITION
        end
      end
    end
  end
end
