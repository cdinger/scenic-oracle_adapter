# frozen_string_literal: true

require "rails/railtie"
require "active_record/connection_adapters/oracle_enhanced_adapter"

module Scenic
  module Adapters
    class Oracle
      class Railtie < Rails::Railtie
        ActiveSupport.on_load(:active_record) do
          if defined?(ActiveRecord::ConnectionAdapters::OracleEnhancedSchemaDumper)
            ActiveRecord::ConnectionAdapters::OracleEnhancedSchemaDumper.prepend Scenic::SchemaDumper
          else
            ActiveRecord::ConnectionAdapters::OracleEnhanced::SchemaDumper.prepend Scenic::SchemaDumper
          end
        end
      end
    end
  end
end
