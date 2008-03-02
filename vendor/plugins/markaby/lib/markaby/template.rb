module Markaby
  class Template

    def self.builder_class=(builder)
      @@builder_class = builder
    end
      
    def self.builder_class
      @@builder_class ||= Builder
    end
    
    attr_accessor :source, :path
    
    def initialize(source)
      @source = source.to_s
    end

    def render(*args)
      output = self.class.builder_class.new(*args)

      if path.nil?
        output.instance_eval source
      else
        output.instance_eval source, path
      end
      
      return output.to_s
    end

  end
end
