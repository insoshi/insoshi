$:.unshift 'lib'
require 'microformat'

class XFN < Microformat
  @@valid_relations = %w( 
    contact
    acquaintance
    friend
    met
    co-worker
    colleague
    co-resident
    neighbor
    child
    parent
    sibling
    spouse
    kin
    muse
    crush
    date
    sweetheart
    me
  )

  class Link < OpenStruct
    def initialize(*args)
      super
      def relation.has?(value)
        is_a?(Array) ? include?(value) : self == value
      end
    end

    def to_html
      %[<a href="#{link}" rel="#{Array(relation) * ' '}">#{name}</a>]
    end
    
    def to_s
      link
    end
  end

  attr_accessor :links

  def self.find_occurences(doc)
    case doc
    when Hpricot::Doc then @occurences = XFN.new(doc)
    else @occurences 
    end
  end

  class << self
    alias :find_first :find_occurences
    alias :find_every :find_occurences
  end
  
  def initialize(doc)
    @links = doc.search("a[@rel]").map do |rl| 
      relation = rl[:rel].split(' ') 

      # prune invalid relations
      relation.each { |r| relation.delete(r) unless @@valid_relations.include? r }
      relation = relation.first if relation.size == 1
      next if relation.empty?

      Link.new(:name => rl.innerHTML, :link => rl[:href], :relation => relation)
    end.compact
  end

  def relations
    @relations ||= @links.map { |l| l.relation }
  end
  
  def [](*rels)
    @links.select do |link| 
      relation = link.relation
      relation.respond_to?(:all?) && rels.all? { |rel| relation.include? rel }
    end.first_or_self
  end

  def method_missing(method, *args, &block)
    method = method.to_s
    if (rels = method.split(/_and_/)).size > 1
      self[*rels]
    elsif @links.class.public_instance_methods.include? method
      @links.send(method, *args, &block)
    else
      check = args.first == true ? :== : :has?
      @links.select { |link| link.relation.send(check, method) }.first_or_self
    end
  end
end
