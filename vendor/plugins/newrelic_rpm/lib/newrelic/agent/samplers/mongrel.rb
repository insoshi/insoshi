# NewRelic Instrumentation for Mongrel - tracks the queue length of the mongrel server
if defined? Mongrel::HttpServer
  
  agent = NewRelic::Agent.instance
  mongrel = nil;
  ObjectSpace.each_object(Mongrel::HttpServer) do |mongrel_instance|
    # should only be one mongrel instance in the vm
    if mongrel
      agent.log.info("Discovered multiple mongrel instances in one Ruby VM.  "+
        "This is unexpected and might affect the Accuracy of the Mongrel Request Queue metric.")
    end

    mongrel = mongrel_instance
  end

  if mongrel
    agent.stats_engine.add_sampled_metric("Mongrel/Queue Length") do |stats|
      qsize = mongrel.workers.list.length
      stats.record_data_point qsize
    end
  end

end