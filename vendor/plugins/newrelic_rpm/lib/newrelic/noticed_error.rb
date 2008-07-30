# this class encapsulates an error that was noticed by RPM in a managed app.
# NOTE we do not capture the stack trace because RPM does not have
# access to the app's source code, so it has little value and is
# sizeable.  We can add this later if customers demand it. (The stack
# trace will obviously be available elsewhere like the logs...)
class NoticedError
  attr_accessor :path, :timestamp, :params, :exception_class, :message
  
  def initialize(controller_path, params, exception)
    self.params = params
    self.path = controller_path
    self.timestamp = Time.now
    
    self.exception_class = exception.class.name
    self.message = exception.message
    
  end
end