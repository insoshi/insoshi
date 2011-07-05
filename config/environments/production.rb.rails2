# Settings specified here will take precedence over those in config/environment.rb
require 'active_support/cache/dalli_store23'

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# for Heroku
config.logger = Logger.new(STDOUT)
config.cache_store = :dalli_store

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

config.active_record.colorize_logging = true
