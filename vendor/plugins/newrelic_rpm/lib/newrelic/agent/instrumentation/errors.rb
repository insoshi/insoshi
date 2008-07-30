

# patch rescue_action and track how many are occuring and capture instances as well

if defined? ActionController

module ActionController
  class Base
    def rescue_action_with_newrelic_trace(exception)
      self.class.trace_method_execution("Errors/all", false, true, nil) do
        NewRelic::Agent.agent.error_collector.notice_error(_determine_metric_path,
              params, exception)
        rescue_action_without_newrelic_trace exception
      end
    end
    
    # Compare with #alias_method_chain, which is not available in 
    # Rails 1.1:
    alias_method :rescue_action_without_newrelic_trace, :rescue_action
    alias_method :rescue_action, :rescue_action_with_newrelic_trace
    private :rescue_action
  end
end

end