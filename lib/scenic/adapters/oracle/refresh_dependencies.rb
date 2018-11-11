# frozen_string_literal: true

require "tsort"

module Scenic
  module Adapters
    class Oracle
      class RefreshDependencies
        def self.call(name, adapter, connection)
          new(name, adapter, connection).call
        end

        def initialize(name, adapter, connection)
          @name = name
          @adapter = adapter
          @connection = connection
        end

        def call
          dependencies.each do |dependency|
            adapter.refresh_materialized_view(dependency)
          end
        end

        private

        attr_reader :name, :adapter, :connection

        def dependencies
          d = dependency_tree_for(@name)
          each_node = ->(&b) { d.each_key(&b) }
          each_child = ->(n, &b) { d[n].each(&b) }
          TSort.tsort(each_node, each_child) - [@name]
        end

        def dependency_tree_for(name, tree = {})
          ds = connection.select_values(<<~EOSQL)
            select referenced_name
            from user_dependencies
            where name = '#{name.upcase}'
              and referenced_type = 'MATERIALIZED VIEW'
          EOSQL

          tree[name.downcase.to_sym] = Array(ds).map { |x| x.downcase.to_sym }
          ds.each { |d| dependency_tree_for(d, tree) }
          tree
        end
      end
    end
  end
end
