module ActiveScaffold::DataStructures
  class ActionLinks
    include Enumerable

    def initialize
      @set = []
    end

    # adds an ActionLink, creating one from the arguments if need be
    def add(action, options = {})
      link = action.is_a?(ActiveScaffold::DataStructures::ActionLink) ? action : ActiveScaffold::DataStructures::ActionLink.new(action, options)
      # NOTE: this duplicate check should be done by defining the comparison operator for an Action data structure
      @set << link unless @set.any? {|a| a.action == link.action and a.controller == link.controller and a.parameters == link.parameters}
    end
    alias_method :<<, :add

    # finds an ActionLink by matching the action
    def [](val)
      @set.find {|item| item.action == val.to_s}
    end

    def delete(val)
      index_to_delete = nil
      @set.each_with_index {|item, index| index_to_delete = index; break if item.action == val.to_s}
      @set.delete_at(index_to_delete) unless index_to_delete.nil?
    end

    # iterates over the links, possibly by type
    def each(type = nil)
      type = type.to_sym if type
      @set.each {|item|
        next if type and item.type != type
        yield item
      }
    end

    def empty?
      @set.size == 0
    end

    protected

    # called during clone or dup. makes the clone/dup deeper.
    def initialize_copy(from)
      @set = []
      from.instance_variable_get('@set').each { |link| @set << link.clone }
    end
  end
end