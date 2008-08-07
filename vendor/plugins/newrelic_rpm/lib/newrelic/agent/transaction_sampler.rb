require 'newrelic/transaction_sample'
require 'thread'
require 'newrelic/agent/method_tracer'
require 'newrelic/agent/synchronize'

module NewRelic::Agent
  class TransactionSampler
    include(Synchronize)
    
    def initialize(agent, options = {})
      @samples = []
      
      @options = {:max_samples => 100, :record_sql => :obfuscated}
      @options.merge!(options)

      @max_samples = @options[:max_samples]

      agent.stats_engine.add_scope_stack_listener self

      agent.set_sql_obfuscator(:replace) do |sql| 
        default_sql_obfuscator(sql)
      end
    end
    
    
    def default_sql_obfuscator(sql)
#      puts "obfuscate: #{sql}"
      
      # remove escaped strings
      sql = sql.gsub("''", "?")
      
      # replace all string literals
      sql = sql.gsub(/'[^']*'/, "?")
      
      # replace all number literals
      sql = sql.gsub(/\d+/, "?")
      
#      puts "result: #{sql}"
      
      sql
    end
    
    
    def notice_first_scope_push
      create_builder
    end
    
    def notice_push_scope(scope)
      with_builder do |builder|
        builder.trace_entry(scope)
        
        # in developer mode, capture the stack trace with the segment.
        # this is cpu and memory expensive and therefore should not be
        # turned on in production mode
        if ::RPM_DEVELOPER
          segment = builder.current_segment
          if segment
            # NOTE we manually inspect stack traces to determine that the 
            # agent consumes the last 8 frames.  Review after we make changes
            # to transaction sampling or stats engine to make sure this remains
            # a true assumption
            trace = caller(8)
            
            trace = trace[0..40] if trace.length > 40
            segment[:backtrace] = trace
          end
        end
      end
    end
    
    def scope_depth
      depth = 0
      with_builder do |builder|
        depth = builder.scope_depth
      end
      
      depth
    end
  
    def notice_pop_scope(scope)
      with_builder do |builder|
        builder.trace_exit(scope)
      end
    end
    
    def notice_scope_empty
      with_builder do |builder|
        builder.finish_trace
        reset_builder
      
        synchronize do
          sample = builder.sample
        
          # ensure we don't collect more than a specified number of samples in memory
          @samples << sample if ::RPM_DEVELOPER && sample.params[:path] != nil
          @samples.shift while @samples.length > @max_samples
          
          if @slowest_sample.nil? || @slowest_sample.duration < sample.duration
            @slowest_sample = sample
          end
        end
      end
    end
    
    def notice_transaction(path, request, params)
      with_builder do |builder|
        builder.set_transaction_info(path, request, params)
      end
    end
    
    def notice_transaction_cpu_time(cpu_time)
      with_builder do |builder|
        builder.set_transaction_cpu_time(cpu_time)
      end
    end
    
    
    # params == a hash of parameters to add
    #
    def add_request_parameters(params)
      with_builder do |builder|
        builder.add_request_parameters(params)
      end
    end
    
    # some statements (particularly INSERTS with large BLOBS
    # may be very large; we should trim them to a maximum usable length
    MAX_SQL_LENGTH = 16384
    def notice_sql(sql, config)
    
      if (@options[:record_sql] != :off) && (Thread::current[:record_sql].nil? || Thread::current[:record_sql])
        with_builder do |builder|
          segment = builder.current_segment
          if segment
            current_sql = segment[:sql]
            sql = current_sql + ";\n" + sql if current_sql

            if sql.length > (MAX_SQL_LENGTH - 4)
              sql = sql[0..MAX_SQL_LENGTH-4] + '...'
            end
            
            segment[:sql] = sql
            segment[:connection_config] = config
          end
        end
      end
    end
    
    # get the set of collected samples, merging into previous samples,
    # and clear the collected sample list. 
    
    def harvest_slowest_sample(previous_slowest = nil)
      synchronize do
        slowest = @slowest_sample
        @slowest_sample = nil

        return nil unless slowest

        if previous_slowest.nil? || previous_slowest.duration < slowest.duration
          slowest
        else
          previous_slowest
        end
      end
    end

    # get the list of samples without clearing the list.
    def get_samples
      synchronize do
        return @samples.clone
      end
    end
    
    private 
      BUILDER_KEY = :transaction_sample_builder

      def create_builder
        Thread::current[BUILDER_KEY] = TransactionSampleBuilder.new
      end
      
      # most entry points into the transaction sampler take the current transaction
      # sample builder and do something with it.  There may or may not be a current
      # transaction sample builder on this thread. If none is present, the provided
      # block is not called (saving sampling overhead); if one is, then the 
      # block is called with the transaction sample builder that is registered
      # with this thread.
      def with_builder
        builder = get_builder
        yield builder if builder
      end
      
      def get_builder
        Thread::current[BUILDER_KEY]
      end
      
      def reset_builder
        Thread::current[BUILDER_KEY] = nil
      end
      
      def is_developer_mode?
        @developer_mode ||= (defined?(::RPM_DEVELOPER) && ::RPM_DEVELOPER)
      end
  end

  # a builder is created with every sampled transaction, to dynamically
  # generate the sampled data.  It is a thread-local object, and is not
  # accessed by any other thread so no need for synchronization.
  class TransactionSampleBuilder
    attr_reader :current_segment
    
    def initialize
      @sample = NewRelic::TransactionSample.new
      @sample.begin_building
      @current_segment = @sample.root_segment
    end

    def trace_entry(metric_name)
      segment = @sample.create_segment(relative_timestamp, metric_name)
      @current_segment.add_called_segment(segment)
      @current_segment = segment
    end

    def trace_exit(metric_name)
      if metric_name != @current_segment.metric_name
        fail "unbalanced entry/exit: #{metric_name} != #{@current_segment.metric_name}"
      end
      
      @current_segment.end_trace relative_timestamp
      @current_segment = @current_segment.parent_segment
    end
    
    def finish_trace
      # This should never get called twice, but in a rare case that we can't reproduce in house it does.
      # log forensics and return gracefully
      if @sample.frozen?
        log = self.class.method_tracer_log
        
        log.warn "Unexpected double-freeze of Transaction Trace Object."
        log.info "Please send this diagnostic data to New Relic"
        log.info @sample.to_s
        return
      end
      
      @sample.root_segment.end_trace relative_timestamp
      @sample.freeze
      @current_segment = nil
    end
    
    def scope_depth
      depth = -1        # have to account for the root
      current = @current_segment
      
      while(current)
        depth += 1
        current = current.parent_segment
      end
      
      depth
    end
    
    def freeze
      @sample.freeze unless sample.frozen?
    end
    
    def relative_timestamp
      Time.now - @sample.start_time
    end
    
    def set_transaction_info(path, request, params)
      @sample.params[:path] = path
      @sample.params[:request_params].merge!(params)
      @sample.params[:request_params].delete :controller
      @sample.params[:request_params].delete :action
      @sample.params[:uri] = request.path if request
    end
    
    def set_transaction_cpu_time(cpu_time)
      @sample.params[:cpu_time] = cpu_time
    end
    
    def add_request_parameters(params)
      @sample.params[:request_params].merge!(params)
    end
    
    def sample
      fail "Not finished building" unless @sample.frozen?
      @sample
    end
    
  end
end