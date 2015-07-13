worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)
timeout 30         # restarts workers that hang for 30 seconds
preload_app true   # so things go good

before_fork do |server, worker|
	ActiveRecord::Base.connection_handler.clear_all_connections!
end

after_fork do |server, worker|
	ActiveRecord::Base.connection_handler.verify_active_connections!
end
