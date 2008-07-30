

class MockScopeListener
  
  attr_reader :scope
  
  def initialize
    @scope = {}
  end
  
  def notice_first_scope_push()
  end

  def notice_push_scope(scope)
    @scope[scope] = true
  end

  def notice_pop_scope(scope)
  end

  def notice_scope_empty()
    
  end
end