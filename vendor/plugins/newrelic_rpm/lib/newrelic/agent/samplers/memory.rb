module NewRelic::Agent
  class MemorySampler
    def initialize
      if RUBY_PLATFORM =~ /java/
        platform = %x[uname -s].downcase
      else
        platform = RUBY_PLATFORM.downcase
      end
      
      # macos, linux, solaris
      if platform =~ /darwin|linux/
        @ps = "ps -o rsz #{$$}"
      elsif platform =~ /freebsd/
        @ps = "ps -o rss #{$$}"
      elsif platform =~ /solaris/
        @ps = "ps -o rss -p #{$$}"
      end
      if !@ps
        raise SamplerInitFailure, "Unsupported platform for getting memory: #{platform}"
      end
      
      if @ps
        agent = NewRelic::Agent.instance
        agent.stats_engine.add_sampled_metric("Memory/Physical") do |stats|
          return if @broken
          memory = `#{@ps}`.split("\n")[1].to_f / 1024
          
          # if for some reason the ps command doesn't work on the resident os,
          # then don't execute it any more.
          if memory > 0
            stats.record_data_point memory
            
          else 
            NewRelic::Agent.instance.log.error "Error attempting to determine resident memory.  Disabling this metric."
            NewRelic::Agent.instance.log.error "Faulty command: `#{@ps}`"
            @broken = true
          end
        end
      end
    end
  end
end

NewRelic::Agent::MemorySampler.new
