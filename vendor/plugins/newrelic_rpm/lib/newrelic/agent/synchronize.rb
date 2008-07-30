
require 'sync'


module NewRelic::Agent
  
  module Synchronize
    def synchronize_sync(&block)
      @_local_sync ||= Sync.new
      
      @_local_sync.synchronize(:EX) do
        block.call
      end
    end
    
    
    def synchronize_mutex(&block)
      @_local_mutex ||= Mutex.new
      
      @_local_mutex.synchronize do
        block.call
      end
    end
  
    
    def synchronize_thread
      old_val = Thread.critical
      
      Thread.critical = true
      
      begin
        yield
      ensure
        Thread.critical = old_val
      end
    end
    
    
    alias synchronize synchronize_mutex
    alias synchronize_quick synchronize_mutex
    alias synchronized_long synchronize_mutex
  end   
end
