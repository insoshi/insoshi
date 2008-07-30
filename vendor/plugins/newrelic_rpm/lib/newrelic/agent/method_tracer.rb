require 'logger'

class Module
  DEFAULT_METHOD_TRACE_LOG = Logger.new(STDERR)
  DEFAULT_METHOD_TRACE_LOG.level = Logger::ERROR
  
  # the class accessor for the instrumentation log
  def method_tracer_log
    @@method_trace_log ||= DEFAULT_METHOD_TRACE_LOG
  end
  
  def method_tracer_log= (log)
    @@method_trace_log = log
  end
  
  #
  # it might be cleaner to have a hash for options, however that's going to be slower
  # than direct parameters
  #
  def trace_method_execution (metric_name, push_scope, produce_metric, deduct_call_time_from_parent)
    
    t0 = Time.now
    stats = nil
    expected_scope = nil
    
    begin
      stats_engine = NewRelic::Agent.agent.stats_engine
      
      expected_scope = stats_engine.push_scope(metric_name, t0, deduct_call_time_from_parent) if push_scope
      
      stats = stats_engine.get_stats metric_name, push_scope if produce_metric
    rescue => e
      method_tracer_log.error("Caught exception in trace_method_execution header. Metric name = #{metric_name}, exception = #{e}")
      method_tracer_log.error(e.backtrace.join("\n"))
    end

    begin
      result = yield
    ensure
      t1 = Time.now
      
      duration = t1 - t0
      
      begin
        if expected_scope
          scope = stats_engine.pop_scope expected_scope, duration
          
          exclusive = duration - scope.children_time
        else
          exclusive = duration
        end

        stats.trace_call duration, exclusive if stats
      rescue => e
        method_tracer_log.error("Caught exception in trace_method_execution footer. Metric name = #{metric_name}, exception = #{e}")
        method_tracer_log.error(e.backtrace.join("\n"))
      end
    
      result 
    end
  end

  # Add a method tracer to the specified method.  
  # metric_name_code is ruby code that determines the name of the
  # metric to be collected during tracing.  As such, the code
  # should be provided in 'single quote' strings rather than
  # "double quote" strings, so that #{} evaluation happens
  # at traced method execution time.
  # Example: tracing a method :foo, where the metric name is
  # the first argument converted to a string
  #     add_method_tracer :foo, '#{args.first.to_s}'
  # statically defined metric names can be specified as regular strings
  # push_scope specifies whether this method tracer should push
  # the metric name onto the scope stack.
  def add_method_tracer (method_name, metric_name_code, options = {})
    return unless ::RPM_TRACERS_ENABLED
    
    if !options.is_a?(Hash)
      options = {:push_scope => options} 
    end
    
    options[:push_scope] = true if options[:push_scope].nil?
    options[:metric] = true if options[:metric].nil?
    options[:deduct_call_time_from_parent] = false if options[:deduct_call_time_from_parent].nil? && !options[:metric]
    options[:deduct_call_time_from_parent] = true if options[:deduct_call_time_from_parent].nil?
    options[:code_header] ||= ""
    options[:code_footer] ||= ""
    
    klass = (self === Module) ? "self" : "self.class"
    
    unless method_defined?(method_name) || private_method_defined?(method_name)
      method_tracer_log.warn("Did not trace #{self}##{method_name} because that method does not exist")
      return
    end
    
    traced_method_name = _traced_method_name(method_name, metric_name_code)
    if method_defined? traced_method_name
      method_tracer_log.warn("Attempt to trace a method twice with the same metric: Method = #{method_name}, Metric Name = #{metric_name_code}")
      return
    end
    
    code = <<-CODE
    def #{_traced_method_name(method_name, metric_name_code)}(*args, &block)
      #{options[:code_header]}
      metric_name = "#{metric_name_code}"
      traced_method_result = #{klass}.trace_method_execution("\#{metric_name}", #{options[:push_scope]}, #{options[:metric]}, #{options[:deduct_call_time_from_parent]}) do
        #{_untraced_method_name(method_name, metric_name_code)}(*args, &block)
      end
      #{options[:code_footer]}
      traced_method_result
    end
    CODE
  
    class_eval code, __FILE__, __LINE__
  
    alias_method _untraced_method_name(method_name, metric_name_code), method_name
    alias_method method_name, "#{_traced_method_name(method_name, metric_name_code)}"
    
    method_tracer_log.debug("Traced method: class = #{self}, method = #{method_name}, "+
        "metric = '#{metric_name_code}', options: #{options}, ")
  end

  # Not recommended for production use, because tracers must be removed in reverse-order
  # from when they were added, or else other tracers that were added to the same method
  # may get removed as well.
  def remove_method_tracer(method_name, metric_name_code)
    return unless ::RPM_TRACERS_ENABLED
    
    if method_defined? "#{_traced_method_name(method_name, metric_name_code)}"
      alias_method method_name, "#{_untraced_method_name(method_name, metric_name_code)}"
      undef_method "#{_traced_method_name(method_name, metric_name_code)}"
    else
      raise "No tracer for '#{metric_name_code}' on method '#{method_name}'"
    end
  end

private
  def _untraced_method_name(method_name, metric_name)
    "#{_sanitize_name(method_name)}_without_trace_#{_sanitize_name(metric_name)}" 
  end
  
  def _traced_method_name(method_name, metric_name)
    "#{_sanitize_name(method_name)}_with_trace_#{_sanitize_name(metric_name)}" 
  end
  
  def _sanitize_name(name)
    name.to_s.tr('^a-z,A-Z,0-9', '_')
  end
end
