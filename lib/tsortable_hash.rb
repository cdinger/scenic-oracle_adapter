require "tsort"

class TSortableHash < Hash
  include TSort

  alias_method :tsort_each_node, :each_key
  def tsort_each_child(node, &)
    fetch(node).each(&)
  end
end
