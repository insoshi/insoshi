require 'yaml'
require 'newrelic/agent/method_tracer'

def to_stderr(s)
  STDERR.puts "** [NewRelic] " + s
end

# Initializer for the NewRelic Agent
config_filename = File.join(File.dirname(__FILE__), '..','..','..','config','newrelic.yml')
begin catch (:disabled) do 
  begin
    newrelic_config_file = File.read(config_filename)
  rescue => e
    to_stderr e
    to_stderr "Could not read configuration file #{config_filename}."
    to_stderr "Be sure to put newrelic.yml into your config directory."
    to_stderr "Agent is disabled."
    throw :disabled
  end

  begin
    newrelic_agent_config = YAML.load(newrelic_config_file)[RAILS_ENV] || {}
  rescue Exception => e
    to_stderr "Error parsing #{config_filename}"
    to_stderr "#{e}"
    to_stderr "Agent is disabled."
    throw :disabled
  end
  newrelic_agent_config.freeze
  ::NR_CONFIG_FILE = newrelic_agent_config
  
  ::RPM_AGENT_ENABLED = newrelic_agent_config['enabled']
  ::RPM_DEVELOPER = newrelic_agent_config['developer']
  
  # Check to see if the agent should be enabled or not

  # note if the agent is not turned on via the enabled flag in the 
  # configuration file, the application will be untouched, and it will
  # behave exaclty as if the agent were never installed in the first place.

  ::RPM_TRACERS_ENABLED = ::RPM_DEVELOPER || ::RPM_AGENT_ENABLED

  if !::RPM_TRACERS_ENABLED || ENV['NEWRELIC_ENABLE'] && ENV['NEWRELIC_ENABLE'] =~ /false|off|no/i
    require 'newrelic/shim_agent'
    throw :disabled 
  end
  
  require 'newrelic/agent'
  
  agent = NewRelic::Agent.instance
  agent.start(newrelic_agent_config)
  
  # When (and only when) RPM is running in developer mode, a few pages
  # are added to your application that present performance information
  # on the last 100 http requests your application has handled, allowing
  # you to diagnose performance problems on your desktop.
  #
  # to see this information, visit http://localhost:3000/newrelic
  if ::RPM_DEVELOPER
    controller_path = File.join(File.dirname(__FILE__), 'ui', 'controllers')
    helper_path = File.join(File.dirname(__FILE__), 'ui', 'helpers')
    $LOAD_PATH << controller_path
    $LOAD_PATH << helper_path
    Dependencies.load_paths << controller_path
    Dependencies.load_paths << helper_path
    config.controller_paths << controller_path
    require 'newrelic_routing'
    
    # inform user that the dev edition is available if we are running inside
    # a webserver process
    if agent.local_port
      to_stderr "NewRelic Agent (Developer Mode) enabled."
      to_stderr "To view performance information, go to http://localhost:#{agent.local_port}/newrelic"
    end
  end
end
rescue Exception => e
  to_stderr "Error initializing New Relic plugin"
  to_stderr "#{e}"
  to_stderr e.backtrace.join("\n")
  to_stderr "Agent is disabled."
end
