require 'delayed_job'
require 'rails'

module Delayed
  class Railtie < Rails::Railtie
    initializer :after_initialize do
      Delayed::Worker.guess_backend
    end
  end
end
