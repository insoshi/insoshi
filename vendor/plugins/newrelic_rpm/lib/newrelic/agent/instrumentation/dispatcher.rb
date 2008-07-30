require 'dispatcher'


NR_DISPATCHER_CODE_HEADER = <<-CODE

NewRelic::Agent.agent.start_transaction

if Thread.current[:started_on]
  stats = NewRelic::Agent.agent.stats_engine.get_stats 'WebFrontend/Mongrel/Average Queue Time', false
  stats.trace_call Time.now - Thread.current[:started_on]
end

CODE

# NewRelic RPM instrumentation for http request dispatching (Routes mapping)
# Note, the dispatcher class from no module into into the ActionController modile 
# in rails 2.0.  Thus we need to check for both
if defined? ActionController::Dispatcher

  class ActionController::Dispatcher

    class << self
      add_method_tracer :dispatch, 'Rails/HTTP Dispatch', :push_scope => false, 
        :code_header => NR_DISPATCHER_CODE_HEADER
    end
    
  end
  
elsif defined? Dispatcher

  class Dispatcher
    class << self
      add_method_tracer :dispatch, 'Rails/HTTP Dispatch', :push_scope => false, 
        :code_header => NR_DISPATCHER_CODE_HEADER
    end
  end

end