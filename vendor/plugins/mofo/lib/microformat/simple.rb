require 'microformat'

class Microformat
  class Simple < String
    extend Microformat::Base

    def self.find_first(doc)
      find_every(doc).first
    end

    def self.find_occurences(doc)
      @from ? doc/from_as_xpath : super
    end

    def self.build_class(tag)
      new(tag.innerText || '')
    end

    def self.from(options)
      @from ||= []
      options.each do |tag, value|
        @from << "@#{tag}=#{value}"
      end
    end

    def self.from_as_xpath
      "[#{@from.to_a * "|"}]"
    end
  end
end
