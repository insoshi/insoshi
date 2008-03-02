module Markaby
  # Class used by Markaby::Builder to store element options.  Methods called
  # against the CssProxy object are added as element classes or IDs.
  #
  # See the README for examples.
  class CssProxy

    # Creates a CssProxy object.
    def initialize(builder, stream, sym)
      @builder, @stream, @sym, @attrs = builder, stream, sym, {}
      
      @original_stream_length = @stream.length
      
      @builder.tag! @sym
    end
    
    # Adds attributes to an element.  Bang methods set the :id attribute.
    # Other methods add to the :class attribute.
    def method_missing(id_or_class, *args, &block)
      if (idc = id_or_class.to_s) =~ /!$/
        @attrs[:id] = $`
      else
        @attrs[:class] = @attrs[:class].nil? ? idc : "#{@attrs[:class]} #{idc}".strip
      end

      unless args.empty?
        if args.last.respond_to? :to_hash
          @attrs.merge! args.pop.to_hash
        end
      end
      
      args.push(@attrs)
      
      while @stream.length > @original_stream_length
        @stream.pop
      end
      
      if block
        @builder.tag! @sym, *args, &block
      else
        @builder.tag! @sym, *args
      end
      
      return self
    end

  end
end
