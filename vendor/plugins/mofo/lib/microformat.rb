%w(rubygems set hpricot microformat/string microformat/array open-uri ostruct timeout).each { |f| require f }
gem 'hpricot', '>=0.4.59'

class Microformat
  module Base
    @@subclasses = Set.new
    @@timeout    = 5

    ##
    # The Gateway
    #
    def find(*args)
      return find_in_children(*args) if self == Microformat

      target, @options = args
      @options ||= target.is_a?(Hash) ? target : {}
      [:first, :all].each { |key| target = @options[key] if @options[key] }

      extract_base_url! target
      
      @doc = build_doc(@options[:text] ? @options : target)

      microformats = find_occurences(@doc)
      raise MicroformatNotFound if @options[:strict] && microformats.empty?
      return @options[:first] ? nil : [] if microformats.empty?

      if @options[:first] || @options[:all]
        return @options[:first] ? find_first(microformats) : find_every(microformats)
      end

      object = find_every(microformats)
      case object.size
      when 1 then object.first
      when 0 then nil
      else object
      end
    end

    def find_in_children(*args)
      @@subclasses.map do |klass|
        klass.find(*args)
      end.flatten
    end

    # i have no idea what the hell this is doing
    names_and_keys = proc do |attributes| 
      attributes.map do |att|
        att.respond_to?(:keys) ? att.keys.first : att 
      end
    end

    define_method :attributes do
      names_and_keys[@attributes[:many] + @attributes[:one]]
    end

    %w(many one).each do |type|
      define_method("#{type}s") do
        names_and_keys[@attributes[type.intern]]
      end
    end

    def timeout=(timeout)
      @@timeout = timeout
    end

  protected
    ##
    # DSL Related
    # 
    def after_find(&block)
      @after_find_procs ||= Hash.new { |h,k| h[k] = [] }
      @after_find_procs[name] << block if block_given?
      @after_find_procs[name]
    end
    alias :after_finds :after_find

    def inherited(klass)
      @@subclasses << klass
      define_cute_class_name(klass)
      current_container = @container
      klass.class_eval do
        @container  = current_container || name.downcase
        @attributes = Hash.new { |h,k| h[k] = [] }
      end
    end

    def define_cute_class_name(klass)
      return unless (name = klass.name) =~ /^H/
      Object.send(:define_method, name.sub(/^H/, 'h')) { klass }
    end

    def collector
      collector = Hash.new([])
      def collector.method_missing(method, *classes)
        super unless %w(one many).include? method.to_s
        self[method] += Microformat.send(:break_out_hashes, classes)
      end
      collector
    end

    def container(container)
      @container = container.to_s
    end

    def method_missing(method, *args, &block)
      super unless %w(one many).include? method.to_s
      (collected = collector).instance_eval(&block) if block_given?
      classes = block_given? ? [args.first => collected] : break_out_hashes(args)
      @attributes[method] += classes
    end

    def break_out_hashes(array)
      array.inject([]) do |memo, element|
        memo + (element.is_a?(Hash) ? [element.map { |k,v| { k => v } }].flatten : [element])
      end
    end

    def aliases(hash)
      define_method(hash.keys.first) do
        send(hash[hash.keys.first])
      end
    end

    ##
    # The Functionality
    #
    def find_first(doc)
      build_class(doc.first)
    end

    def find_every(doc)
      doc.inject([]) do |array, entry|
        array + [build_class(entry)]
      end
    end

    def build_doc(source)
      case source
      when String, File, StringIO     
        result = ''
        Timeout.timeout(@@timeout) { result = open(source) }
        Hpricot(result)
      when Hpricot, Hpricot::Elements 
        source
      when Hash                       
        Hpricot(source[:text]) if source[:text]
      end
    end

    def find_occurences(doc)
      doc/".#{@container}" 
    end

    def build_class(microformat)
      hash = build_hash(microformat)
      class_eval { attr_reader *(hash.keys << :properties) }

      klass = new
      klass.instance_variable_set(:@properties, hash.keys.map { |i| i.to_s } )

      hash.each do |key, value|
        klass.instance_variable_set("@#{key}", prepare_value(value) )
      end

      after_find_callbacks! klass

      klass
    end

    def after_find_callbacks!(object)
      original_ivars = object.instance_variables.dup

      after_finds.each do |block|
        object.instance_eval &block
      end

      Array(object.instance_variables - original_ivars).each do |ivar|
        object.properties << ivar.gsub('@','')
      end
    end

    def build_hash(doc, attributes = @attributes)
      hash = {}

      # rel="bookmark" pattern
      if bookmark = extract_bookmark(doc)
        hash[:bookmark] = bookmark
      end

      # rel="license" pattern
      if license = extract_license(doc)
        hash[:license] = license
      end

      # rel="tag" pattern
      if tags = extract_tags(doc)
        hash[:tags] = tags
      end

      [:one, :many].each do |name|
        attributes[name].each do |attribute|
          is_hash = attribute.is_a? Hash
          key = is_hash ? attribute.keys.first : attribute

          found = doc/".#{key.no_bang.to_s.gsub('_','-')}"
          raise InvalidMicroformat if found.empty? && key.to_s =~ /!/
          next if found.empty?

          if is_hash && attribute[key].is_a?(Hash)
            built_hash = build_hash(found, attribute[key])
            key = key.no_bang
            if built_hash.size.zero? && found.size.nonzero?
              hash[key] = found.map { |f| parse_element(f) }
              hash[key] = hash[key].first if name == :one
            else
              hash[key] = built_hash
            end
          else
            target = is_hash ? attribute[key] : nil
            key = key.no_bang
            if name == :many
              hash[key] ||= [] 
              hash[key] += found.map { |f| parse_element(f, target) }
            else
              hash[key] = parse_element(found.first, target) 
            end
          end
          hash[key] = hash[key].first if hash[key].is_a?(Array) && hash[key].size == 1
        end
      end

      hash.merge extract_includes(doc)
    end

    def extract_includes(doc)
      @includes ||= {}

      doc.search(".include").inject({}) do |hash, element|
        target = element.attributes['data'] || element.attributes['href']

        return @includes[target] if @includes[target]

        unless (includes = @doc/target).empty?
          hash.merge @includes[target] = build_hash(includes)
        else
          hash
        end
      end
    end

    def extract_bookmark(doc)
      bookmark = (doc.at("[@rel=bookmark]") || doc.at("[@rel='self bookmark']")) rescue nil
      bookmark.attributes['href'] if bookmark.respond_to? :attributes
    end

    def extract_license(doc)
      license = doc.at("[@rel=license]") rescue nil
      license.attributes['href'] if license.respond_to? :attributes
    end

    def extract_tags(doc)
      return unless (tags = doc.search("[@rel=tag]")).size.nonzero?
      tags.inject([]) { |array, tag| array + [tag.innerText] }
    end

    def parse_element(element, target = nil)
      if target == :url
        url = case element.name
        when 'img'    then element['src']
        when 'a'      then element['href']
        when 'object' then element['value']
        end
        url[/^http/] ? url : @options[:base_url].to_s + url if url.respond_to?(:[])
      elsif target.is_a? Array
        target.inject(nil) do |found, klass|
          klass = klass.respond_to?(:find) ? klass : nil

          found || parse_element(element, klass)
        end 
      elsif target.is_a? Class
        target.find(@options.merge(:first => element))
      else
        value = case element.name
        when 'abbr' then element['title']
        when 'img'  then element['alt']
        end || ''

        (value.empty? ? element.innerHTML : value).strip.strip_html.coerce
      end
    end

    def prepare_value(value)
      value.is_a?(Hash) ? OpenStruct.new(value) : value
    end

    def extract_base_url!(target)
      @options[:base_url] ||= @options[:base] || @options[:url]
      @options[:base_url] ||= target[/^(http:\/\/[^\/]+)/] if target.respond_to?(:scan) 
    end
  end

  def method_missing(method, *args, &block)
    return super unless method == :properties || @properties.include?(method.to_s)
    self.class.class_eval { define_method(method) { instance_variable_get("@#{method}") } }
    instance_variable_get("@#{method}")
  end

  extend Base
end

class InvalidMicroformat  < Exception; end
class MicroformatNotFound < Exception; end

# oh what the hell, let's do it
Mofo = Microformat

# type & id are used a lot in uformats and deprecated in ruby.  no loss.
OpenStruct.class_eval { undef :type, :id }
Symbol.class_eval { def no_bang() to_s.sub('!','').to_sym end }
