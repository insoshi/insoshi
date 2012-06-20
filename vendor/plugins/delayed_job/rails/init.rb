require 'delayed_job'

config.after_initialize do
  Delayed::Worker.guess_backend
end