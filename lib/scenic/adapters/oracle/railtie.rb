# frozen_string_literal: true

require "rails/railtie"

module Scenic
  module Adapters
    class Oracle
      class Railtie < Rails::Railtie
        ActiveSupport.on_load(:active_record) do
          if Scenic::Adapters::Oracle.uses_oracle_enhanced_adapter?
            require "active_record/connection_adapters/oracle_enhanced_adapter"

            if defined?(ActiveRecord::ConnectionAdapters::OracleEnhancedSchemaDumper)
              ActiveRecord::ConnectionAdapters::OracleEnhancedSchemaDumper.prepend Scenic::SchemaDumper
            else
              ActiveRecord::ConnectionAdapters::OracleEnhanced::SchemaDumper.prepend Scenic::SchemaDumper
            end
          end
          if Scenic::Adapters::Oracle.uses_oracle_adapter?
            require "active_record/connection_adapters/oracle_adapter"

            ActiveRecord::ConnectionAdapters::Oracle::SchemaDumper.prepend Scenic::SchemaDumper
          end
        end
      end
    end
  end
end
