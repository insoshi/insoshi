module NewRelic::Agent
  class CPUSampler
    def initialize
  
      agent = NewRelic::Agent.instance
  
      agent.stats_engine.add_sampled_metric("CPU/User Time") do | stats |
        t = Process.times
        @last_utime ||= t.utime
        
        utime = t.utime
        stats.record_data_point (utime - @last_utime) if (utime - @last_utime) >= 0
        @last_utime = utime
      end
  
      agent.stats_engine.add_sampled_metric("CPU/System Time") do | stats |
        t = Process.times
        @last_stime ||= t.stime
        
        stime = t.stime
        stats.record_data_point (stime - @last_stime) if (stime - @last_stime) >= 0
        @last_stime = stime
      end
    end
  end
end

NewRelic::Agent::CPUSampler.new
