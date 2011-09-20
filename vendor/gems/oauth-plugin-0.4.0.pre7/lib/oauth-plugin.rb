require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/request_proxy/rack_request'
require 'oauth/server'
require 'oauth/controllers/application_controller_methods'
if Rails.version =~ /^3\./
  require 'oauth/request_proxy/rack_request'
else
  require 'oauth/request_proxy/action_controller_request'
  ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
end


module OAuth
  module Plugin
    class OAuthRailtie < Rails::Railtie
      initializer "oauth-plugin.configure_rails_initialization" do |app|
        ActionController::Base.send :include, OAuth::Controllers::ApplicationControllerMethods
      end
    end
  end
end
