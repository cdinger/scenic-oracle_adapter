# frozen_string_literal: true

require "active_record"
# Require tsort here before scenic to avoid:
# uninitialized constant Scenic::Adapters::Postgres::Views::TSortableHash::TSort
require "tsort"
require "scenic"
require "scenic/oracle_adapter/version"
require "scenic/adapters/oracle"
require "scenic/adapters/oracle/railtie" if defined?(Rails)

module Scenic
  module OracleAdapter
  end
end
