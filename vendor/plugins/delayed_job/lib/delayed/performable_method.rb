class Class
  def load_for_delayed_job(arg)
    self
  end
  
  def dump_for_delayed_job
    name
  end
end

module Delayed
  class PerformableMethod < Struct.new(:object, :method, :args)
    STRING_FORMAT = /^LOAD\;([A-Z][\w\:]+)(?:\;(\w+))?$/
    
    class LoadError < StandardError
    end

    def initialize(object, method, args)
      raise NoMethodError, "undefined method `#{method}' for #{object.inspect}" unless object.respond_to?(method, true)

      self.object = dump(object)
      self.args   = args.map { |a| dump(a) }
      self.method = method.to_sym
    end
    
    def display_name
      if STRING_FORMAT === object
        "#{$1}#{$2 ? '#' : '.'}#{method}"
      else
        "#{object.class}##{method}"
      end
    end
    
    def perform
      load(object).send(method, *args.map{|a| load(a)})
    rescue PerformableMethod::LoadError
      # We cannot do anything about objects that can't be loaded
      true
    end

    private

    def load(obj)
      if STRING_FORMAT === obj
        $1.constantize.load_for_delayed_job($2)
      else
        obj
      end
    rescue => e
      Delayed::Worker.logger.warn "Could not load object for job: #{e.message}"
      raise PerformableMethod::LoadError
    end

    def dump(obj)
      if obj.respond_to?(:dump_for_delayed_job)
        "LOAD;#{obj.dump_for_delayed_job}"
      else
        obj
      end
    end
  end
end
