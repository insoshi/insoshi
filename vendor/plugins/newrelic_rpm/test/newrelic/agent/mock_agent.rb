require 'newrelic/agent/stats_engine'

RPM_AGENT_ENABLED = true
module NewRelic
  
  module Agent
    
    class Agent
      attr_reader :stats_engine
      
      private_class_method :new
      @@instance = nil
      
      def Agent.instance
        @@instance = new unless @@instance
        @@instance
      end
      
      def initialize
        @stats_engine = StatsEngine.new 
      end
    end
    
    class << self
      def agent
        NewRelic::Agent::Agent.instance
      end
      
      alias instance agent
    end
  end
end
