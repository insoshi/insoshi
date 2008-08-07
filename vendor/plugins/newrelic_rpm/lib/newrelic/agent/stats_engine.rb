require 'newrelic/stats'
require 'newrelic/metric_data'
require 'logger'

module NewRelic::Agent
  class StatsEngine
    POLL_PERIOD = 10
    
    attr_accessor :log

    ScopeStackElement = Struct.new(:name, :timestamp, :children_time, :deduct_call_time_from_parent)
    
    class SampledItem
      def initialize(stats, &callback)
        @stats = stats
        @callback = callback
      end
      
      def poll
        @callback.call @stats
      end
    end
    
    def initialize(log = Logger.new(STDERR))
      @stats_hash = {}
      @sampled_items = []
      @scope_stack_listeners = []
      @log = log
      
      # Makes the unit tests happy
      Thread::current[:newrelic_scope_stack] = nil
      
      spawn_sampler_thread
    end
    
    def spawn_sampler_thread
      
      return if !@sampler_process.nil? && @sampler_process == $$ 
      
      # start up a thread that will periodically poll for metric samples
      @sampler_thread = Thread.new do
        while true do
          begin
            sleep POLL_PERIOD
            @sampled_items.each do |sampled_item|
              begin 
                sampled_item.poll
              rescue => e
                log.error e
                @sampled_items.delete sampled_item
                log.error "Removing #{sampled_item} from list"
                log.debug e.backtrace.to_s
              end
            end
          end
        end
      end

      @sampler_process = $$
    end
    
    def add_scope_stack_listener(l)
      fail "Can't add a scope listener midflight in a transaction" if scope_stack.any?
      @scope_stack_listeners << l
    end
    
    def push_scope(metric, time = Time.now, deduct_call_time_from_parent = true)
      @scope_stack_listeners.each do |l|
        l.notice_first_scope_push if scope_stack.empty? 
        l.notice_push_scope metric
      end
      
      scope = ScopeStackElement.new(metric, time, 0, deduct_call_time_from_parent)
      scope_stack.push scope
      
      scope
    end
    
    def pop_scope(expected_scope, duration = Time.now - expected_scope.timestamp)
      stack = scope_stack
      
      scope = stack.pop
      
      if scope != expected_scope
	      fail "unbalanced pop from blame stack: #{scope.name} != #{expected_scope.name}"
      end
      
      stack.last.children_time += duration unless (stack.empty? || !scope.deduct_call_time_from_parent)
      
      if !scope.deduct_call_time_from_parent && !stack.empty?
        stack.last.children_time += scope.children_time
      end
      
      @scope_stack_listeners.each do |l|
        l.notice_pop_scope scope.name
        l.notice_scope_empty if scope_stack.empty? 
      end
      
      scope
    end
    
    def peek_scope
      scope_stack.last
    end
    
    def add_sampled_metric(metric_name, &sampler_callback)
      stats = get_stats(metric_name, false)
      @sampled_items << SampledItem.new(stats, &sampler_callback)
    end
    
    # set the name of the transaction for the current thread, which will be used
    # to define the scope of all traced methods called on this thread until the
    # scope stack is empty.  
    #
    # currently the transaction name is the name of the controller action that 
    # is invoked via the dispatcher, but conceivably we could use other transaction
    # names in the future if the traced application does more than service http request
    # via controller actions
    def transaction_name=(transaction)
      Thread::current[:newrelic_transaction_name] = transaction
    end
    
    def transaction_name
      Thread::current[:newrelic_transaction_name]
    end
    
    
    def lookup_stat(metric_name)
      return @stats_hash[NewRelic::MetricSpec.new(metric_name)]
    end
    
    def get_stats(metric_name, use_scope = true)
      spec = NewRelic::MetricSpec.new metric_name
      stats = @stats_hash[spec]
      if stats.nil?
        stats = NewRelic::MethodTraceStats.new
        @stats_hash[spec] = stats
      end
      
      if use_scope && transaction_name
        spec = NewRelic::MetricSpec.new metric_name, transaction_name
        
        scoped_stats = @stats_hash[spec]
        if scoped_stats.nil?
          scoped_stats = NewRelic::ScopedMethodTraceStats.new stats
          @stats_hash[spec] = scoped_stats        
        end
        
        stats = scoped_stats
      end
      return stats
    end
    
    def harvest_timeslice_data(previous_timeslice_data, metric_ids)
      timeslice_data = {}
      
      @stats_hash.keys.each do |metric_spec|
        
        # get a copy of the stats collected since the last harvest, and clear
        # the stats inside our hash table for the next time slice.
        stats = @stats_hash[metric_spec]
        if stats.nil? 
          puts "Nil stats for #{metric_spec.name} (#{metric_spec.scope})"
        end
        
        stats_copy = stats.clone
        stats.reset
        
        # if the previous timeslice data has not been reported (due to an error of some sort)
        # then we need to merge this timeslice with the previously accumulated - but not sent
        # data
        previous_metric_data = previous_timeslice_data[metric_spec]
        stats_copy.merge! previous_metric_data.stats unless previous_metric_data.nil?
        
        stats_copy.round!
        
        # don't bother collecting and reporting stats that have zero-values for this timeslice.
        # significant performance boost and storage savings.
        unless stats_copy.call_count == 0
          metric_data = NewRelic::MetricData.new(metric_spec, stats_copy, metric_ids[metric_spec])
          
          timeslice_data[metric_spec] = metric_data
        end
      end
      
      timeslice_data
    end
    
    
    def start_transaction
      Thread::current[:newrelic_scope_stack] = []
    end
    
    private
    
      def scope_stack
        s = Thread::current[:newrelic_scope_stack]
        if s.nil?
          s = []
          Thread::current[:newrelic_scope_stack] = s
        end
        s
      end
  end
end