

class MockHTTPRequest
  
  attr_accessor :session
  attr_accessor :parameters
  attr_accessor :path
  
  def initialize(params = {})
    @session = {}
    @parameters = params
    @path = "/test"
  end
  
  def parameters
    {}
  end
  
  def session_options=(options)
  end

  def cookies
    {}
  end
  
end


class MockHTTPResponse
  
  attr_accessor :template
  attr_accessor :redirected_to
  attr_accessor :session
  attr_accessor :headers
  attr_accessor :content_type
  attr_accessor :body
  attr_accessor :charset
  attr_accessor :request
  
  def initialize
    @template = MockTemplate.new
    @session = {}
    @headers = {}
  end
  
  def prepare!
  end
  
end


class MockTemplate
  
  def extend(param)
    
  end
  
end