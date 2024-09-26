# frozen_string_literal: true

require "active_support/core_ext/string/indent"

module Scenic
  module Adapters
    class Oracle
      class View < Scenic::View
        def to_schema
          materialized_option = materialized ? "materialized: true, " : ""

          <<-DEFINITION
  create_view #{UnaffixedName.for(name).inspect}, #{materialized_option}sql_definition: <<-\SQL
#{escaped_definition.indent(6)}
  SQL
          DEFINITION
        end
      end
    end
  end
end
