require 'net/https' 
require 'net/http'
require 'logger'
require 'singleton'
require 'zlib'

require 'newrelic/stats'
require 'newrelic/agent/worker_loop'

require 'newrelic/agent/stats_engine'
require 'newrelic/agent/transaction_sampler'
require 'newrelic/agent/error_collector'

# The NewRelic Agent collects performance data from rails applications in realtime as the
# application runs, and periodically sends that data to the NewRelic server.
module NewRelic::Agent
  
  # an exception that is thrown by the server if the agent license is invalid
  class LicenseException < Exception; end
  
  # an exception that forces an agent to stop reporting until its mongrel is restarted
  class ForceDisconnectException < Exception; end
  
  # add some convenience methods for easy access to the Agent singleton.
  # the following static methods all point to the same Agent instance:
  #
  # NewRelic::Agent.agent
  # NewRelic::Agent.instance
  # NewRelic::Agent::Agent.instance
  class << self
    def agent
      NewRelic::Agent::Agent.instance
    end
    
    alias instance agent
    
    # Get or create a statistics gatherer that will aggregate numerical data
    # under a metric name.
    #
    # metric_name should follow a slash separated path convention.  Application
    # specific metrics should begin with "Custom/".
    #
    # the statistical gatherer returned by get_stats accepts data
    # via calls to add_data_point(value)
    def get_stats(metric_name)
      agent.stats_engine.get_stats(metric_name, false)
    end
    
    
    # Call this to manually start the Agent in situations where the Agent does
    # not auto-start.
    # When the rails environment loads, so does the Agent. However, the Agent will
    # only connect to RPM if a web plugin is found. If you want to selectively monitor
    # rails processes that don't use web plugins, then call this method in your
    # code and the Agent will fire up and start reporting to RPM.
    #
    # environment - the name of the environment. used for logging only
    # port - the name of this instance. shows up in the RPM UI screens. can be any String
    #
    def manual_start(environment, port)
      agent.manual_start(environment, port)
    end
    
    # This method sets the block sent to this method as a sql obfuscator. 
    # The block will be called with a single String SQL statement to obfuscate.
    # The method must return the obfuscated String SQL. 
    # If chaining of obfuscators is required, use type = :before or :after
    #
    # type = :before, :replace, :after
    #
    # example:
    #    NewRelic::Agent.set_sql_obfuscator(:replace) do |sql|
    #       my_obfuscator(sql)
    #    end
    # 
    def set_sql_obfuscator(type = :replace, &block)
      agent.set_sql_obfuscator type, &block
    end
    
    
    # This method sets the state of sql recording in the transaction
    # sampler feature. Within the given block, no sql will be recorded
    #
    # usage:
    #
    #   NewRelic::Agent.disable_sql_recording do
    #     ...  
    #    end
    #     
    def disable_sql_recording
      state = agent.set_record_sql(false)
      begin
        yield
      ensure
        agent.set_record_sql(state)
      end
    end
    
    
    # Add parameters to the current transaction trace
    #
    def add_request_parameters(params = {})
      agent.transaction_sampler.add_request_parameters(params)
    end
    
  end
  
  
  
  # Implementation default for the NewRelic Agent
  class Agent
    # Specifies the version of the agent's communication protocol
    # with the NewRelic hosted site.
    #
    # VERSION HISTORY
    # 1: Private Beta, Jan 10, 2008.  Serialized Marshalled Objects.  Unsupported after 5/29/2008.
    # 2: Private Beta, March 15, 2008.  Compressed Serialzed Marshalled Objects (15-20x smaller)
    # 3: June 19, 2008. Added transaction sampler capability with obfuscation
    # 4: July 15, 2008. Added error capture
    PROTOCOL_VERSION = 4
    
    include Singleton
    
    DEFAULT_HOST = 'localhost'
    DEFAULT_PORT = 3000
    
    attr_reader :obfuscator
    attr_reader :stats_engine
    attr_reader :transaction_sampler
    attr_reader :error_collector
    attr_reader :worker_loop
    attr_reader :log
    attr_reader :license_key
    attr_reader :config
    attr_reader :remote_host
    attr_reader :remote_port
    attr_reader :record_sql
    attr_reader :local_port
    
    # Start up the agent, which will connect to the newrelic server and start 
    # reporting performance information.  Typically this is done from the
    # environment configuration file
    def start(config)
      if @started
        log! "Agent Started Already!"
        raise "Duplicate attempt to start the NewRelic agent"
      end
      
      @config = config
      
      @local_port = determine_environment_and_port
      start_reporting if @local_port
    end
    
    # this method makes sure that the agent is running. it's important
    # for passenger where processes are forked and the agent is dormant
    #
    def ensure_started
      return unless @prod_mode_enabled
      if @worker_thread.nil? || !@worker_thread.alive?
        launch_worker_thread
        @stats_engine.spawn_sampler_thread
     end
    end
    
    def start_reporting(force_enable=false)
      @local_host = determine_host

      setup_log
      
      @worker_loop = WorkerLoop.new(@log)
      @started = true
      
      @license_key = config.fetch('license_key', nil)
      
      sampler_config = config.fetch('transaction_tracer', {})
      
      @use_transaction_sampler = sampler_config.fetch('enabled', false)
      @record_sql = (sampler_config.fetch('record_sql', 'obfuscated') || 'off').intern
      @slowest_transaction_threshold = sampler_config.fetch('transaction_threshold', '2.0').to_f
      @explain_threshold = sampler_config.fetch('explain_threshold', '0.5').to_f
      @explain_enabled = sampler_config.fetch('explain_enabled', true)
      
      log.info "Transaction tracer enabled: #{@use_transaction_sampler}"
      log.warn "Agent is configured to send raw SQL to RPM service" if @record_sql == :raw
      
      @use_ssl = config.fetch('ssl', false)
      default_port = @use_ssl ? 443 : 80
      
      @remote_host = config.fetch('host', 'collector.newrelic.com')
      @remote_port = config.fetch('port', default_port)
      
      @proxy_host = config.fetch('proxy_host', nil)
      @proxy_port = config.fetch('proxy_port', nil)
      @proxy_user = config.fetch('proxy_user', nil)
      @proxy_pass = config.fetch('proxy_pass', nil)

      @prod_mode_enabled = force_enable || config['enabled']
      
      # make sure the license key exists and is likely to be really a license key
      # by checking it's string length (license keys are 40 character strings.)
      if @prod_mode_enabled && (!@license_key || @license_key.length != 40)
        log! "No license key found.  Please insert your license key into agent/newrelic.yml"
        return
      end

      instrument_rails if force_enable || ::RPM_TRACERS_ENABLED
      
      if @prod_mode_enabled
        load_samplers
        launch_worker_thread
        install_at_exit_handler
      end
    end
    
    def manual_start(environment, port)
      @environment = environment
      @local_port = port
      
      start_reporting true      
    end

    
    def start_transaction
      @stats_engine.start_transaction
    end
        
    def set_record_sql(should_record)
      prev = Thread::current[:record_sql]
      Thread::current[:record_sql] = should_record
      
      prev || true
    end
    
    def set_sql_obfuscator(type, &block)
      if type == :before
        @obfuscator = ChainedCall.new(block, @obfuscator)
      elsif type == :after
        @obfuscator = ChainedCall.new(@obfuscator, block)
      elsif type == :replace
        @obfuscator = block
      else
        fail "unknown sql_obfuscator type #{type}"
      end
    end

    
    private
    def initialize
      @connected = false
      @launch_time = Time.now
      
      @metric_ids = {}
      @environment = :unknown
      @initalized_pid = $$
      
      @stats_engine = StatsEngine.new
      @transaction_sampler = TransactionSampler.new(self)
      @error_collector = ErrorCollector.new(self)
      
      @request_timeout = 15 * 60
    end
    
    def setup_log
      if @local_port
        log_file = "#{RAILS_ROOT}/log/newrelic_agent.#{@local_port}.log"
      else
        log_file = "#{RAILS_ROOT}/log/newrelic_agent.log"
      end
      
      @log = Logger.new log_file
      @log.level = Logger::INFO
      
      # change the format just for our logger
      
      def @log.format_message(severity, timestamp, progname, msg)
        "[#{timestamp.strftime("%m/%d/%y %H:%M:%S")} (#{$$})] #{severity} : #{msg}\n" 
      end
      
      @stats_engine.log = @log
      
      # set the log level as specified in the config file
      case config.fetch("log_level","info").downcase
        when "debug": @log.level = Logger::DEBUG
        when "info": @log.level = Logger::INFO
        when "warn": @log.level = Logger::WARN
        when "error": @log.level = Logger::ERROR
        when "fatal": @log.level = Logger::FATAL
      else @log.level = Logger::INFO
      end
      
      log! "New Relic RPM Agent Initialized: pid = #{$$}"
      to_stderr "Agent Log is found in #{log_file}"
      log.info "Runtime environment: #{@environment.to_s.titleize}"
    end
    
    
    def launch_worker_thread
      
      # we don't launch the worker_thread for passenger due to the way it spawns processes
      
      return if (@environment == :passenger && @initalized_pid == $$)
      
      @worker_thread = Thread.new do 
        @worker_thread_started = true
        run_worker_loop
      end
    end
    
    # Connect to the server, and run the worker loop forever
    def run_worker_loop
      
      until @connected
        should_retry = connect
        return unless should_retry
      end
            
      # determine the reporting period (server based)
      # note if the agent attempts to report more frequently than the specified
      # report data, then it will be ignored.
      report_period = invoke_remote :get_data_report_period, @agent_id
      log! "Reporting performance data every #{report_period} seconds"        
      @worker_loop.add_task(report_period) do 
        harvest_and_send_timeslice_data
      end
      
      if @should_send_samples && @use_transaction_sampler
        @worker_loop.add_task(report_period) do 
          harvest_and_send_slowest_sample
        end
      end
      
      if @should_send_errors
        @worker_loop.add_task(report_period) do 
          harvest_and_send_errors
        end
      end
      
      @worker_loop.run
    end
    
    
    def install_at_exit_handler
      # When the VM shuts down, attempt to send a message to the server that
      # this agent run is stopping, assuming it has successfully connected
      at_exit do
        @worker_loop.stop
        
        log.debug "Starting Agent shutdown"
        
        # if litespeed, then ignore all future SIGUSR1 - it's litespeed trying to shut us down
        
        if @environment == :litespeed
          Signal.trap("SIGUSR1", "IGNORE")
          Signal.trap("SIGTERM", "IGNORE")
        end
        
        begin
          
          # only call graceful_disconnect if we successfully stop the worker thread (since a transaction may be in flight)
          if @worker_thread.join(30)  
            graceful_disconnect
          else
            log.debug "ERROR - could not stop worker thread"
          end
        rescue Exception => e
          log.debug e
          log.debug e.backtrace.join("\n")
        end
      end
    end    
    
    
    def connect
      @connect_retry_period ||= 5
      @connect_attempts ||= 0
      
      # wait a few seconds for the web server to boot
      sleep @connect_retry_period.to_i
      
      @agent_id = invoke_remote :launch, @local_host,
               @local_port, determine_home_directory, $$, @launch_time.to_f
      
      log! "Connected to NewRelic Service at #{@remote_host}:#{@remote_port}."
      log.debug "Agent ID = #{@agent_id}."
      
      # Ask the server for permission to send transaction samples.  determined by subscription license.
      @should_send_samples = invoke_remote :should_collect_samples, @agent_id
      
      # Ask for mermission to collect error data
      @should_send_errors = invoke_remote :should_collect_errors, @agent_id
      
      log! "Transaction tracer enabled from RPM service: #{@should_send_samples}"
      
      @connected = true
      @last_harvest_time = Time.now
      return true
      
    rescue LicenseException => e
      log! e.message, :error
      log! "Visit NewRelic.com to obtain a valid license key, or to upgrade your account."
      log! "Turning New Relic Agent off."
      return false
      
    rescue Timeout::Error, StandardError => e
      log.error "Error attempting to connect to New Relic RPM Service at #{@remote_host}:#{@remote_port}"
      log.error e.message
      log.debug e.backtrace.join("\n")
      
      # retry logic
      @connect_attempts += 1
      if @connect_attempts > 20
        @connect_retry_period, period_msg = 10.minutes, "10 minutes"
      elsif @connect_attempts > 10
        @connect_retry_period, period_msg = 1.minutes, "1 minute"
      elsif @connect_attempts > 5
        @connect_retry_period, period_msg = 30, nil
      else
        @connect_retry_period, period_msg = 5, nil
      end
      
      log.info "Will re-attempt in #{period_msg}" if period_msg
      return true
    end
    
    def load_samplers
      sampler_files = File.join(File.dirname(__FILE__), 'samplers', '*.rb')
      Dir.glob(sampler_files) do |file|
        begin
          require file
        rescue => e
          log.error "Error loading sampler '#{file}': #{e}"
        end
      end
    end
    
    def determine_host
      Socket.gethostname
    end
    
    # determine the environment we are running in (one of :webrick,
    # :mongrel, :thin, or :unknown) and if the process is listening
    # on a port, return the port # that we are listening on.  When
    # this returns nil for the port, then the agent will not run.
    def determine_environment_and_port
      # Note: log won't be available yet.
      port = nil
      @environment = :unknown
      
      begin
        # OPTIONS is set by script/server 
        port = OPTIONS.fetch :port, DEFAULT_PORT
        @environment = :webrick
        return port
      rescue NameError
      end # continue on if this didn't succeed...

      # this case covers starting by mongrel_rails
      if defined? Mongrel::HttpServer
        ObjectSpace.each_object(Mongrel::HttpServer) do |mongrel|
          @environment = :mongrel
          return mongrel.port
        end
      end
      
      if defined? Thin::Server
        # This case covers the thin web server
        # Same issue as above- we assume only one instance per process
        ObjectSpace.each_object(Thin::Server) do |thin_server|
          @environment = :thin
          backend = thin_server.backend
          # We need a way to uniquely identify and distinguish agents.  The port
          # works for this.  When using sockets, use the socket file name.
          if backend.respond_to? :port
            return backend.port
          elsif backend.respond_to? :socket
            return backend.socket
          end
        end # each thin instance
      end
      
      if RUBY_PLATFORM =~ /java/
        # Check for JRuby environment.  Not sure how this works in different appservers
        require 'java'
        require 'jruby'
        @environment = :jruby
        return java.lang.System.identityHashCode(JRuby.runtime)
      end
      
      if caller.pop =~ /fcgi-bin\/RailsRunner\.rb/
          @environment = :litespeed
          return 'litespeed'
      end
      
      if defined? Passenger::AbstractServer
        @environment = :passenger
        return 'passenger'
      end
      
      if config['monitor_daemons']
        @environment = :daemon
        # return the base part of the file name
        return File.basename($0).split(".").first
      end
      
      # if no real environment was found
      return nil
    end
    
    def determine_home_directory
      File.expand_path(RAILS_ROOT)
    end
    
    def instrument_rails
      @instrumented ||= false
      
      return if @instrumented
      
      @instrumented = true
      
      Module.method_tracer_log = log
      
      # Instrumentation for the key code points inside rails for monitoring by NewRelic.
      # note this file is loaded only if the newrelic agent is enabled (through config/newrelic.yml)
      instrumentation_files = File.join(File.dirname(__FILE__), 'instrumentation', '*.rb')
      Dir.glob(instrumentation_files) do |file|
        begin
          require file
          log.debug "Processed instrumentation file '#{file.split('/').last}'"
        rescue => e
          log.error "Error loading instrumentation file '#{file}': #{e}"
          log.debug e.backtrace.join("\n")
        end
      end
    end
    
    @last_harvest_time = Time.now
    def harvest_and_send_timeslice_data
      now = Time.now
      @unsent_timeslice_data ||= {}
      @unsent_timeslice_data = @stats_engine.harvest_timeslice_data(@unsent_timeslice_data, @metric_ids)
      
      
      begin
        metric_ids = invoke_remote(:metric_data, @agent_id, 
                @last_harvest_time.to_f, 
                now.to_f, 
                @unsent_timeslice_data.values)
      
      rescue Timeout::Error
        # assume that the data was received. chances are that it was
        metric_ids = nil
      end
                
              
      @metric_ids.merge! metric_ids unless metric_ids.nil?
      
      log.debug "#{Time.now}: sent #{@unsent_timeslice_data.length} timeslices (#{@agent_id})"
      
      # if we successfully invoked this web service, then clear the unsent message cache.
      @unsent_timeslice_data.clear
      @last_harvest_time = Time.now
      
      # handle_messages 
      
      # note - exceptions are logged in invoke_remote.  If an exception is encountered here,
      # then the metric data is downsampled for another timeslices
    end
    
    def harvest_and_send_slowest_sample
      @slowest_sample = @transaction_sampler.harvest_slowest_sample(@slowest_sample)
      
      if @slowest_sample && @slowest_sample.duration > @slowest_transaction_threshold
        log.debug "Sending slowest sample: #{@slowest_sample.params[:path]}, #{@slowest_sample.duration.round_to(2)} s" if @slowest_sample
        
        # take the slowest sample, and prepare it for sending across the wire.  This includes
        # gathering SQL explanations, stripping out stack traces, and normalizing SQL.
        # note that we explain only the sql statements whose segments' execution times exceed 
        # our threshold (to avoid unnecessary overhead of running explains on fast queries.)
        sample = @slowest_sample.prepare_to_send(:explain_sql => @explain_threshold, :record_sql => @record_sql, :explain_enabled => @explain_enabled)

        invoke_remote :transaction_sample_data, @agent_id, sample
      end
      
      # if we succeed sending this sample, then we don't need to keep the slowest sample
      # around - it has been sent already and we can collect the next one
      @slowest_sample = nil
      
      # note - exceptions are logged in invoke_remote.  If an exception is encountered here,
      # then the slowest sample of is determined of the entire period since the last
      # reported sample.
    end
    
    def harvest_and_send_errors
      @unsent_errors = @error_collector.harvest_errors(@unsent_errors)
      if @unsent_errors && @unsent_errors.length > 0
        log.debug "Sending #{@unsent_errors.length} errors"

        invoke_remote :error_data, @agent_id, @unsent_errors
        
        # if the remote invocation fails, then we never clear @unsent_errors,
        # and therefore we can re-attempt to send on the next heartbeat.  Note
        # the error collector maxes out at 20 instances to prevent leakage
        @unsent_errors = []
      end
    end
    
    def handle_messages(messages)
      messages.each do |message|
        begin
          message = Marshal.load(message)
          message.execute(self)
          log.debug("Received Message: #{message.to_yaml}")
        rescue => e
          log.error "Error handling message: #{e}"
          log.debug e.backtrace.join("\n")
        end
      end 
    end
    
    # send a message via post
    # As of Version 2, the agent-server protocol is:
    # params[:method] => method name(string)
    # params[:license_key] => license key(string)
    # params[:version] => protocol version(integer, 2 or higher)
    def invoke_remote(method, *args)
      # we currently optimize for CPU here since we get roughly a 10x reduction in
      # message size with this, and CPU overhead is at a premium.  If we wanted
      # to go for higher compression instead, we could use Zlib::BEST_COMPRESSION and 
      # pay a little more CPU.
      post_data = CGI::escape(Zlib::Deflate.deflate(Marshal.dump(args), Zlib::BEST_SPEED))
      
      # Proxy returns regular HTTP if @proxy_host is nil (the default)
      request = Net::HTTP::Proxy(@proxy_host, @proxy_port, @proxy_user, @proxy_pass).new(@remote_host, @remote_port.to_i)
      if @use_ssl
        request.use_ssl = true 
        request.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      
      request.read_timeout = @request_timeout
      
      # we'd like to use to_query but it is not present in all supported rails platforms
      # params = {:method => method, :license_key => license_key, :protocol_version => PROTOCOL_VERSION }
      # uri = "/agent_listener/invoke_raw_method?#{params.to_query}"
      uri = "/agent_listener/invoke_raw_method?method=#{method}&license_key=#{license_key}&protocol_version=#{PROTOCOL_VERSION}"
      
      log.debug "#{uri}"
      
      response = request.start do |http|
        http.post(uri, post_data) 
      end

      if response.is_a? Net::HTTPSuccess
        return_value = Marshal.load(Zlib::Inflate.inflate(CGI::unescape(response.body)))
        if return_value.is_a? Exception
          raise return_value
        else
          return return_value
        end
      else
        raise "#{response.code}: #{response.message}"
      end 
    rescue ForceDisconnectException => e
      log! "RPM forced this agent to disconnect", :error
      log! e.message, :error
      log! "Restart this process to resume RPM's agent communication with NewRelic.com"
      # when a disconnect is requested, stop the current thread, which is the worker thread that 
      # gathers data and talks to the server. 
      @connected = false
      Thread.exit

    rescue Exception => e
      log.error("Error communicating with RPM Service at #{@remote_host}:#{remote_port}: #{e}")
      log.debug(e.backtrace.join("\n"))
      raise e
    end
    
    # send the given message to STDERR as well as the agent log, so that it shows
    # up in the console.  This should be used for important informational messages at boot
    def log!(msg, level = :info)
      to_stderr msg
      log.send level, msg if log
    end
    
    def to_stderr(msg)
      # only log to stderr when we are running as a mongrel process, so it doesn't
      # muck with daemons and the like.
      unless @environment == :unknown
        STDERR.puts "** [NewRelic] " + msg 
      end
    end
    
    def graceful_disconnect
      if @connected && !(remote_host == "localhost" && @port == 3000)
        begin
          log.debug "Sending graceful shutdown message to #{remote_host}:#{remote_port}"
          
          @request_timeout = 30
          
          harvest_and_send_timeslice_data
          
          if @should_send_samples && @use_transaction_sampler
            harvest_and_send_slowest_sample
          end
          
          if @should_send_errors
            harvest_and_send_errors
          end
          
          if @environment != :litespeed
            log.debug "Sending RPM service agent run shutdown message"
            invoke_remote :shutdown, @agent_id, Time.now.to_f
          end
          
          log.debug "Graceful shutdown complete"
          
        rescue Timeout::Error, StandardError => e
          log.warn "Error sending shutdown message to #{remote_host}:#{remote_port}:"
          log.warn e
          log.debug e.backtrace.join("\n")
        end
      end
    end
  end
  
end

class ChainedCall

  def initialize(call1, call2)
    @call1 = call1
    @call2 = call2
  end
  
  def call(sql)
    sql = @call1.call(sql)
    @call2.call(sql)
  end
end
