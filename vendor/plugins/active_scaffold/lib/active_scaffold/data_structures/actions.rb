class ActiveScaffold::DataStructures::Actions
  include Enumerable

  def initialize(*args)
    @set = []
    self.add *args
  end

  def exclude(*args)
    args.collect! { |a| a.to_sym } # symbolize the args
    @set.reject! { |m| args.include? m } # reject all actions specified
  end

  def add(*args)
    args.each { |arg| @set << arg.to_sym unless @set.include? arg.to_sym }
  end
  alias_method :<<, :add

  def each
    @set.each {|item| yield item}
  end

  def include?(val)
    super val.to_sym
  end

  # swaps one element in the list with the other.
  # accepts arguments in any order. it just figures out which one is in the list and which one is not.
  def swap(one, two)
    if include? one
      exclude one
      add two
    else
      exclude two
      add one
    end
  end

  protected

  # called during clone or dup. makes the clone/dup deeper.
  def initialize_copy(from)
    @set = from.instance_variable_get('@set').clone
  end
end