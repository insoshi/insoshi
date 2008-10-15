

class ActiveRecord::Base
  
  # Allow skipping of specific callbacks.
  # See http://integrumbles.com/2007/12/12/skipping-activerecord-callback-methods
  def self.skip_callback(callback, &block)
    method = instance_method(callback)
    remove_method(callback) if respond_to?(callback)
    define_method(callback){ true }
    begin
      result = yield
    ensure 
      # Always redefine the old callback, even if 
      # there were exceptions raised in the yielded block
      remove_method(callback)
      define_method(callback, method)
    end
    result
  end
end
