require 'markaby/tags'

module Markaby
  # The Markaby::Builder class is the central gear in the system.  When using
  # from Ruby code, this is the only class you need to instantiate directly.
  #
  #   mab = Markaby::Builder.new
  #   mab.html do
  #     head { title "Boats.com" }
  #     body do
  #       h1 "Boats.com has great deals"
  #       ul do
  #         li "$49 for a canoe"
  #         li "$39 for a raft"
  #         li "$29 for a huge boot that floats and can fit 5 people"
  #       end
  #     end
  #   end
  #   puts mab.to_s
  #
  class Builder

    @@default = {
      :indent => 0,
      :output_helpers => true,
      :output_xml_instruction => true,
      :output_meta_tag => true,
      :auto_validation => true,
      :tagset => Markaby::XHTMLTransitional,
      :root_attributes => {
        :xmlns => 'http://www.w3.org/1999/xhtml', :'xml:lang' => 'en', :lang => 'en'
      }
    }

    def self.set(option, value)
      @@default[option] = value
    end

    def self.ignored_helpers 
      @@ignored_helpers ||= [] 
    end 
 
    def self.ignore_helpers(*helpers) 
      ignored_helpers.concat helpers 
    end 

    attr_accessor :output_helpers, :tagset

    # Create a Markaby builder object.  Pass in a hash of variable assignments to
    # +assigns+ which will be available as instance variables inside tag construction
    # blocks.  If an object is passed in to +helpers+, its methods will be available
    # from those same blocks.
    #
    # Pass in a +block+ to new and the block will be evaluated.
    #
    #   mab = Markaby::Builder.new {
    #     html do
    #       body do
    #         h1 "Matching Mole"
    #       end
    #     end
    #   }
    #
    def initialize(assigns = {}, helpers = nil, &block)
      @streams = [[]]
      @assigns = assigns.dup
      @helpers = helpers
      @elements = {}

      @@default.each do |k, v|
        instance_variable_set("@#{k}", @assigns.delete(k) || v)
      end
      
      @assigns.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      @builder = XmlMarkup.new(:indent => @indent, :target => @streams.last)

      text(capture(&block)) if block
    end

    # Returns a string containing the HTML stream.  Internally, the stream is stored as an Array.
    def to_s
      @streams.last.to_s
    end

    # Write a +string+ to the HTML stream without escaping it.
    def text(string)
      @builder << string.to_s
      nil
    end
    alias_method :<<, :text
    alias_method :concat, :text

    # Captures the HTML code built inside the +block+.  This is done by creating a new
    # stream for the builder object, running the block and passing back its stream as a string.
    #
    #   >> Markaby::Builder.new.capture { h1 "TEST"; h2 "CAPTURE ME" }
    #   => "<h1>TITLE</h1>\n<h2>CAPTURE ME</h2>\n"
    #
    def capture(&block)
      @streams.push(@builder.target = [])
      @builder.level += 1
      str = instance_eval(&block)
      str = @streams.last.join if @streams.last.any?
      @streams.pop
      @builder.level -= 1
      @builder.target = @streams.last
      str
    end

    # Create a tag named +tag+. Other than the first argument which is the tag name,
    # the arguments are the same as the tags implemented via method_missing.
    def tag!(tag, *args, &block)
      ele_id = nil
      if @auto_validation and @tagset
          if !@tagset.tagset.has_key?(tag)
              raise InvalidXhtmlError, "no element `#{tag}' for #{tagset.doctype}"
          elsif args.last.respond_to?(:to_hash)
              attrs = args.last.to_hash
              
              if @tagset.forms.include?(tag) and attrs[:id]
                attrs[:name] ||= attrs[:id]
              end
              
              attrs.each do |k, v|
                  atname = k.to_s.downcase.intern
                  unless k =~ /:/ or @tagset.tagset[tag].include? atname
                      raise InvalidXhtmlError, "no attribute `#{k}' on #{tag} elements"
                  end
                  if atname == :id
                      ele_id = v.to_s
                      if @elements.has_key? ele_id
                          raise InvalidXhtmlError, "id `#{ele_id}' already used (id's must be unique)."
                      end
                  end
              end
          end
      end
      if block
        str = capture(&block)
        block = proc { text(str) }
      end

      f = fragment { @builder.method_missing(tag, *args, &block) }
      @elements[ele_id] = f if ele_id
      f
    end

    # This method is used to intercept calls to helper methods and instance
    # variables.  Here is the order of interception:
    #
    # * If +sym+ is a helper method, the helper method is called
    #   and output to the stream.
    # * If +sym+ is a Builder::XmlMarkup method, it is passed on to the builder object.
    # * If +sym+ is also the name of an instance variable, the
    #   value of the instance variable is returned.
    # * If +sym+ has come this far and no +tagset+ is found, +sym+ and its arguments are passed to tag!
    # * If a tagset is found, though, +NoMethodError+ is raised.
    #
    # method_missing used to be the lynchpin in Markaby, but it's no longer used to handle
    # HTML tags.  See html_tag for that.
    def method_missing(sym, *args, &block)
      if @helpers.respond_to?(sym, true) && !self.class.ignored_helpers.include?(sym)
        r = @helpers.send(sym, *args, &block)
        if @output_helpers and r.respond_to? :to_str
          fragment { @builder << r }
        else
          r
        end
      elsif @assigns.has_key?(sym)
        @assigns[sym]
      elsif @assigns.has_key?(stringy_key = sym.to_s)
        # Rails' ActionView assigns hash has string keys for
        # instance variables that are defined in the controller.
        @assigns[stringy_key]
      elsif instance_variables.include?(ivar = "@#{sym}")
        instance_variable_get(ivar)
      elsif !@helpers.nil? && @helpers.instance_variables.include?(ivar)
        @helpers.instance_variable_get(ivar)
      elsif ::Builder::XmlMarkup.instance_methods.include?(sym.to_s) 
        @builder.__send__(sym, *args, &block)
      elsif @tagset.nil?
        tag!(sym, *args, &block)
      else
        raise NoMethodError, "no such method `#{sym}'"
      end
    end

    # Every HTML tag method goes through an html_tag call.  So, calling <tt>div</tt> is equivalent
    # to calling <tt>html_tag(:div)</tt>.  All HTML tags in Markaby's list are given generated wrappers
    # for this method.
    #
    # If the @auto_validation setting is on, this method will check for many common mistakes which
    # could lead to invalid XHTML.
    def html_tag(sym, *args, &block)
      if @auto_validation and @tagset.self_closing.include?(sym) and block
        raise InvalidXhtmlError, "the `#{sym}' element is self-closing, please remove the block"
      elsif args.empty? and block.nil?
        CssProxy.new(self, @streams.last, sym)
      else
        tag!(sym, *args, &block)
      end
    end

    XHTMLTransitional.tags.each do |k|
      class_eval %{
        def #{k}(*args, &block)
          html_tag(#{k.inspect}, *args, &block)
        end
      }
    end

    remove_method :head
    
    # Builds a head tag.  Adds a <tt>meta</tt> tag inside with Content-Type
    # set to <tt>text/html; charset=utf-8</tt>.
    def head(*args, &block)
      tag!(:head, *args) do
        tag!(:meta, "http-equiv" => "Content-Type", "content" => "text/html; charset=utf-8") if @output_meta_tag
        instance_eval(&block)
      end
    end

    # Builds an html tag.  An XML 1.0 instruction and an XHTML 1.0 Transitional doctype
    # are prepended.  Also assumes <tt>:xmlns => "http://www.w3.org/1999/xhtml",
    # :lang => "en"</tt>.
    def xhtml_transitional(attrs = {}, &block)
      self.tagset = Markaby::XHTMLTransitional
      xhtml_html(attrs, &block)
    end

    # Builds an html tag with XHTML 1.0 Strict doctype instead.
    def xhtml_strict(attrs = {}, &block)
      self.tagset = Markaby::XHTMLStrict
      xhtml_html(attrs, &block)
    end

    private

    def xhtml_html(attrs = {}, &block)
      instruct! if @output_xml_instruction
      declare!(:DOCTYPE, :html, :PUBLIC, *tagset.doctype)
      tag!(:html, @root_attributes.merge(attrs), &block)
    end

    def fragment
      stream = @streams.last
      start = stream.length
      yield
      length = stream.length - start
      Fragment.new(stream, start, length)
    end

  end

  # Every tag method in Markaby returns a Fragment.  If any method gets called on the Fragment,
  # the tag is removed from the Markaby stream and given back as a string.  Usually the fragment
  # is never used, though, and the stream stays intact.
  #
  # For a more practical explanation, check out the README.
  class Fragment < ::Builder::BlankSlate
    def initialize(*args)
      @stream, @start, @length = args
    end
    def method_missing(*args, &block)
      # We can't do @stream.slice!(@start, @length),
      # as it would invalidate the @starts and @lengths of other Fragment instances.
      @str = @stream[@start, @length].to_s
      @stream[@start, @length] = [nil] * @length
      def self.method_missing(*args, &block)
        @str.send(*args, &block)
      end
      @str.send(*args, &block)
    end
  end

  class XmlMarkup < ::Builder::XmlMarkup
    attr_accessor :target, :level
  end
  
end
