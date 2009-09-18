class ConstMocker
  def initialize(*const_names)
    @const_names = const_names
    @const_states = {}
    @const_names.each{|const_name|
      @const_states[const_name] = Object.const_defined?(const_name) ? Object.const_get(const_name) : nil
    }
  end
  
  def remove
    @const_names.each{|const_name|
      Object.send :remove_const, const_name if Object.const_defined?(const_name)
    }
  end
  
  def declare
    @const_names.each{|const_name|
      Object.class_eval "class #{const_name}; end;" unless Object.const_defined?(const_name)
    }
  end
  
  def restore
    remove
    
    @const_states.each_pair{|const_name, const|
      Object.const_set const_name, const if const
    }
  end
  
  def self.mock(*const_names, &block)
    cm = new(*const_names)
    yield(cm)
    cm.restore
    true
  end
end
