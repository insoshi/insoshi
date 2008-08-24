require 'newrelic/agent/synchronize'

# A worker loop executes a set of registered tasks on a single thread.  
# A task is a proc or block with a specified call period in seconds.  
module NewRelic::Agent
  
  class WorkerLoop
    include(Synchronize)
    
    attr_reader :log
    
    def initialize(log = Logger.new(STDERR))
      @tasks = []
      @log = log
      @should_run = true
    end

    # run infinitely, calling the registered tasks at their specified
    # call periods.  The caller is responsible for creating the thread
    # that runs this worker loop
    def run
      while(@should_run) do
        run_next_task
      end
    end
    
    
    def stop
      @should_run = false
    end

    MIN_CALL_PERIOD = 0.1
    
    # add a task to the worker loop.  The task will be called approximately once
    # every call_period seconds.  The task is passed as a block
    def add_task(call_period, &task_proc)
      if call_period < MIN_CALL_PERIOD
        raise ArgumentError, "Invalid Call Period (must be > #{MIN_CALL_PERIOD}): #{call_period}" 
      end
      
      synchronize do 
        @tasks << LoopTask.new(call_period, &task_proc)
      end
    end
      
    private 
      def get_next_task
        synchronize do
          return @tasks.inject do |soonest, task|
            (task.next_invocation_time < soonest.next_invocation_time) ? task : soonest
          end
        end
      end
    
      def run_next_task
        if @tasks.empty?
          sleep 1.0
          return
        end
        
        # get the next task to be executed, which is the task with the lowest (ie, soonest)
        # next invocation time.
        task = get_next_task
  
        # sleep until this next task's scheduled invocation time
        sleep_time = task.next_invocation_time - Time.now
        
        # sleep in chunks no longer than 1 second
        while sleep_time > 0
          
          sleep (sleep_time > 1 ? 1 : sleep_time)
            
          return if !@should_run
          
          sleep_time -= 1
        end
        
        begin
          task.execute
        rescue Timeout::Error, StandardError => e
          log.debug "Error running task in Agent Worker Loop: #{e}" 
          log.debug e.backtrace.join("\n")
        end
      end
      
      class LoopTask
      
        def initialize(call_period, &task_proc)
          @call_period = call_period
          @last_invocation_time = Time.now
          @task = task_proc
        end
      
        def next_invocation_time
          @last_invocation_time + @call_period
        end
      
        def execute
          @last_invocation_time = Time.now
          @task.call
        end
      end
  end
end
