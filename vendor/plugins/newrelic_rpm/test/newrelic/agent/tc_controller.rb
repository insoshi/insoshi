
require 'test/unit'
require 'vendor/rails/actionpack/lib/action_controller'

::RPM_TRACERS_ENABLED = true

require 'newrelic/agent/method_tracer'
require 'newrelic/agent/instrumentation/action_controller'
require 'newrelic/agent/mock_http'
require 'newrelic/agent'
require 'mocha'



class TestController < ActionController::Base
  filter_parameter_logging :social_security_number
  
  def _filter_parameters(params)
    filter_parameters params
  end
end


   
class AgentControllerTests < Test::Unit::TestCase
  
  
  def test_controller_params
    
    return
    
    agent = NewRelic::Agent.instance
    
    assert agent
    
    assert agent.transaction_sampler
    
    controller = TestController.new
    
    assert_equal 0, NewRelic::Agent.instance.transaction_sampler.get_samples.length
    
    assert_equal "[FILTERED]", controller._filter_parameters({'social_security_number' => 'test'})['social_security_number']
    
    controller.process(MockHTTPRequest.new('social_security_number' => "001-555-1212"), MockHTTPResponse.new)
    
    samples = NewRelic::Agent.instance.transaction_sampler.get_samples
    
    NewRelic::Agent.instance.transaction_sampler.expects(:notice_transaction).never
    
    assert_equal 1, samples.length
    
    puts "Request Params: #{samples[0].params[:request_params]}"

#    assert_equal "[FILTERED]", samples[0].params[:request_params]['social_security_number']
  end  
  
end
