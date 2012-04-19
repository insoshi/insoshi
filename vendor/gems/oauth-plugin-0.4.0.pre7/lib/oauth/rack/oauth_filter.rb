require "rack"
require "rack/request"
require "oauth"
require "oauth/request_proxy/rack_request"

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
        env["oauth_plugin"] = true
        strategies = []
        if token_string = oauth2_token(request)
          if token = Oauth2Token.first(:conditions => ['invalidated_at IS NULL AND authorized_at IS NOT NULL and token = ?', token_string])
            env["oauth.token"]   = token
            env["oauth.version"] = 2
            strategies << :oauth20_token
            strategies << :token
          end

        elsif oauth1_verify(request) do |request_proxy|
            client_application = ClientApplication.find_by_key(request_proxy.consumer_key)
            env["oauth.client_application_candidate"] = client_application

            # Store this temporarily in client_application object for use in request token generation
            client_application.token_callback_url = request_proxy.oauth_callback if request_proxy.oauth_callback
            oauth_token = nil

            if request_proxy.token
              oauth_token = client_application.tokens.first(:conditions => { :token => request_proxy.token })
              if oauth_token.respond_to?(:provided_oauth_verifier=)
                oauth_token.provided_oauth_verifier = request_proxy.oauth_verifier
              end
              env["oauth.token_candidate"] = oauth_token
            end
            # return the token secret and the consumer secret
            [(oauth_token.nil? ? nil : oauth_token.secret), (client_application.nil? ? nil : client_application.secret)]
        end
          if env["oauth.token_candidate"]
            env["oauth.token"] = env["oauth.token_candidate"]
            strategies << :oauth10_token
            if env["oauth.token"].is_a?(::RequestToken)
              strategies << :oauth10_request_token
            elsif env["oauth.token"].is_a?(::AccessToken)
              strategies << :token
              strategies << :oauth10_access_token
            end
          else
            strategies << :two_legged
          end
          env["oauth.client_application"] = env["oauth.client_application_candidate"]
          env["oauth.version"] = 1

        end
        env["oauth.strategies"] = strategies unless strategies.empty?
        env["oauth.client_application_candidate"] = nil
        env["oauth.token_candidate"] = nil
        @app.call(env)
      end

      def oauth1_verify(request, options = {}, &block)
        begin
          signature = OAuth::Signature.build(request, options, &block)
          return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
          value = signature.verify
          value
        rescue OAuth::Signature::UnknownSignatureMethod => e
          false
        end
      end

      def oauth2_token(request)
        request.params['bearer_token'] || request.params['access_token'] || (request.params["oauth_token"] && !request.params["oauth_signature"] ? request.params["oauth_token"] : nil )  ||
          request.env["HTTP_AUTHORIZATION"] &&
          !request.env["HTTP_AUTHORIZATION"][/(oauth_version="1.0")/] &&
          request.env["HTTP_AUTHORIZATION"][/^(Bearer|OAuth|Token) ([^\s]*)$/, 2]
      end
    end
  end
end