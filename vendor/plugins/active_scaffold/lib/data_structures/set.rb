module ActiveScaffold::DataStructures
  class Set
    include Enumerable
    include ActiveScaffold::Configurable

    attr_writer :label
    def label
      as_(@label)
    end

    def initialize(*args)
      @set = []
      self.add *args
    end

    # the way to add items to the set.
    def add(*args)
      args.flatten! # allow [] as a param
      args.each { |arg|
        arg = arg.to_sym if arg.is_a? String
        @set << arg unless @set.include? arg # avoid duplicates
      }
    end
    alias_method :<<, :add

    # the way to remove items from the set.
    def exclude(*args)
      args.flatten! # allow [] as a param
      args.collect! { |a| a.to_sym } # symbolize the args
      @set.reject! { |c| args.include? c.to_sym } # reject all items specified
    end
    alias_method :remove, :exclude

    # returns an array of items with the provided names
    def find_by_names(*names)
      @set.find_all { |item| names.include? item }
    end

    # returns the item of the given name.
    def find_by_name(name)
      # this works because of `def item.=='
      item = @set.find { |c| c == name }
      item
    end
    alias_method :[], :find_by_name

    def each
      @set.each {|i| yield i }
    end

    # returns the number of items in the set
    def length
      @set.length
    end
    
    def empty?
      @set.empty?
    end

  end
end