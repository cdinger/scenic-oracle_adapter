# frozen_string_literal: true

require "active_record"
require "scenic"
require "scenic/oracle_adapter/version"
require "scenic/adapters/oracle"
require "scenic/adapters/oracle/railtie" if defined?(Rails)

module Scenic
  module OracleAdapter
  end
end
