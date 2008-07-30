
require 'test/unit'
require 'newrelic/agent/testable_agent'



class TestSync
  include NewRelic::Agent::Synchronize
  
end


class AgentTests < Test::Unit::TestCase
  

  def test_sync
    t = TestSync.new
    
    worked = false
    t.synchronize_sync do
      worked = true
    end
    
    assert worked
    
    worked = false
    
    t.synchronize_mutex do
      worked = true
    end
    
    assert worked
    
    worked = false
    
    t.synchronize_thread do
      worked = true
    end
    
    assert worked
  end
end
