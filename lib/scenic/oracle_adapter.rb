# frozen_string_literal: true

require "active_record"
# Require tsort here before scenic to avoid:
# uninitialized constant Scenic::Adapters::Postgres::Views::TSortableHash::TSort
require "tsort"
require "scenic"
require "scenic/oracle_adapter/version"
require "scenic/adapters/oracle"
require "scenic/adapters/oracle/railtie" if defined?(Rails)
require "scenic/view"

module Scenic
  module OracleAdapter
  end

  class View
    attr_reader :no_data

    def initialize(name:, definition:, materialized:, no_data: false)
      @name = name
      @definition = definition
      @materialized = materialized
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
