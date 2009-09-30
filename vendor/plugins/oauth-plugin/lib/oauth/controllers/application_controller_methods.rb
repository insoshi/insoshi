require 'oauth/signature'
module OAuth
  module Controllers
   
    module ApplicationControllerMethods
      protected
      
      def current_token
        @current_token
      end
      
      def current_client_application
        @current_client_application
      end
      
      def oauthenticate
        verified=verify_oauth_signature 
        return verified && current_token.is_a?(::AccessToken)
      end
      
      def oauth?
        current_token!=nil
      end
      
      # use in a before_filter
      def oauth_required
        if oauthenticate
          if authorized?
            return true
          else
            invalid_oauth_response
          end
        else          
          invalid_oauth_response
        end
      end
      
      # This requies that you have an acts_as_authenticated compatible authentication plugin installed
      def login_or_oauth_required
        if oauthenticate
          if authorized?
            return true
          else
            invalid_oauth_response
          end
        else
          login_required
        end
      end
      
      
      # verifies a request token request
      def verify_oauth_consumer_signature
        begin
          valid = ClientApplication.verify_request(request) do |request_proxy|
            @current_client_application = ClientApplication.find_by_key(request_proxy.consumer_key)
            
            # Store this temporarily in client_application object for use in request token generation 
            @current_client_application.token_callback_url=request_proxy.oauth_callback if request_proxy.oauth_callback
            
            # return the token secret and the consumer secret
            [nil, @current_client_application.secret]
          end
        rescue
          valid=false
        end

        invalid_oauth_response unless valid
      end

      def verify_oauth_request_token
        verify_oauth_signature && current_token.is_a?(::RequestToken)
      end

      def invalid_oauth_response(code=401,message="Invalid OAuth Request")
        render :text => message, :status => code
      end

      private
      
      def current_token=(token)
        @current_token=token
        if @current_token
          @current_user=@current_token.user
          @current_client_application=@current_token.client_application 
        end
        @current_token
      end
      
      # Implement this for your own application using app-specific models
      def verify_oauth_signature
        begin
          valid = ClientApplication.verify_request(request) do |request_proxy|
            self.current_token = ClientApplication.find_token(request_proxy.token)
            if self.current_token.respond_to?(:provided_oauth_verifier=)
              self.current_token.provided_oauth_verifier=request_proxy.oauth_verifier 
            end
            # return the token secret and the consumer secret
            [(current_token.nil? ? nil : current_token.secret), (current_client_application.nil? ? nil : current_client_application.secret)]
          end
          # reset @current_user to clear state for restful_...._authentication
          @current_user = nil if (!valid)
          valid
        rescue
          false
        end
      end
    end
  end
end