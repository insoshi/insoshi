gem 'oauth', '>=0.3.5'
require 'oauth/signature/hmac/sha1'
require 'oauth/request_proxy/action_controller_request'
require 'oauth/server'
require 'oauth/controllers/application_controller_methods'

ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
