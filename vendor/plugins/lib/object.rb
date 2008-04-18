class Object



  def in?(*args)
    collection = (args.length == 1 ? args.first : args)
    collection.include?(self)
  end




  def not_in?(*args)
    collection = (args.length == 1 ? args.first : args)
    !collection.include?(self)
  end
  
  
  

  def if_nil out = nil
    return out if nil?
    self
  end
  
  def if_method_nil method, out = nil
    return out if nil?
    return send(method) if out.nil?
    return out if respond_to?(method) && send(method).nil?
    send method
  end


  
  def valid_email?
    false
  end
end

