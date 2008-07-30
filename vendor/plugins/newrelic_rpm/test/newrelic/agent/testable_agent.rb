
require 'newrelic/agent'


RAILS_ROOT='.' if !defined? RAILS_ROOT


class String
  def titleize
    self
  end
end


module NewRelic::Agent
    class Agent
      public :determine_environment_and_port
      attr_accessor :environment
    end
end
