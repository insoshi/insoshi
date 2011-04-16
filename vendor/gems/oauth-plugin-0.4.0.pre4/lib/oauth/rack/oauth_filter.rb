require "rack"
require "rack/request"
require "oauth/signature"
module OAuth
  module Rack
    
    # An OAuth 1.0a filter to be used together with the oauth-plugin for rails.T
    # This is still experimental
    #
    # Add it as middleware to your config/application.rb:
    #
    # require 'oauth/rack/oauth_filter'
    # config.middleware.use OAuth::Rack::OAuthFilter
    
    
    
    class OAuthFilter
      def initialize(app)
        @app = app
      end
      
      def call(env)        
        request = ::Rack::Request.new(env)
        env["oauth_plugin"]=true
        if ClientApplication.verify_request(request) do |request_proxy|
            client_application = ClientApplication.find_by_key(request_proxy.consumer_key)
            env["oauth.client_application_candidate"] = client_application
            # Store this temporarily in client_application object for use in request token generation 
            client_application.token_callback_url=request_proxy.oauth_callback if request_proxy.oauth_callback
            
            oauth_token = client_application.tokens.first(:conditions=>{:token => request_proxy.token})
            if oauth_token.respond_to?(:provided_oauth_verifier=)
              oauth_token.provided_oauth_verifier=request_proxy.oauth_verifier 
            end
            env["oauth.token_candidate"] = oauth_token
            # return the token secret and the consumer secret
            [(oauth_token.nil? ? nil : oauth_token.secret), (client_application.nil? ? nil : client_application.secret)]
          end
          env["oauth.token"] = env["oauth.token_candidate"]
          env["oauth.client_application"] = env["oauth.client_application_candidate"]
#          Rails.logger.info "oauth.token = #{env["oauth.token"].inspect}"
        end
        env["oauth.client_application_candidate"] = nil
        env["oauth.token_candidate"] = nil
        response = @app.call(env)
      end
    end
    
  end
end