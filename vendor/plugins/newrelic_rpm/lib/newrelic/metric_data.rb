module NewRelic
  module Metrics
    CONTROLLER = "Controller"
    ACTIVE_RECORD = "ActiveRecord"
    USER_TIME = "CPU/User Time"
    MEMORY = "Memory/Physical"
  end
  
  # this struct uniquely defines a metric, optionally inside
  # the call scope of another metric
  class MetricSpec
    attr_accessor   :name
    attr_accessor   :scope
    
    def initialize (name, scope = nil)
      self.name = name
      self.scope = scope
    end
    
    def eql? (o)
      if scope.nil? 
        return name.eql?(o.name)
      end
      name.eql?(o.name) && scope.eql?(o.scope)
    end
    
    def hash
      h = name.hash
      h += scope.hash unless scope.nil?
      h
    end
    
    def <=>(o)
      namecmp = name <=> o.name
      return namecmp if namecmp != 0
      
      # i'm sure there's a more elegant way to code this correctly, but at least this passes
      # my unit test
      if scope.nil? && o.scope.nil?
        return 0
      elsif scope.nil?
        return -1
      elsif o.scope.nil?
        return 1
      else
        return scope <=> o.scope
      end
    end
  end
  
  class MetricData
    attr_accessor :metric_spec
    attr_accessor :metric_id
    attr_accessor :stats
    
    def initialize(metric_spec, stats, metric_id)
      self.metric_spec = metric_spec
      self.stats = stats
      self.metric_id = metric_id
    end
    
    def eql?(o)
     (metric_spec.eql? o.metric_spec) && (stats.eql? o.stats)
    end
    
    def hash
      metric_spec.hash + stats.hash
    end
    
    def to_s
      "#{metric_spec.name}(#{metric_spec.scope}): #{stats}"
    end
  end
end
