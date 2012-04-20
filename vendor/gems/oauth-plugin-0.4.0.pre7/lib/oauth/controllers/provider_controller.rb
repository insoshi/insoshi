require 'oauth/provider/authorizer'
module OAuth
  module Controllers

    module ProviderController
      def self.included(controller)
        controller.class_eval do
          before_filter :login_required, :only => [:authorize,:revoke]
          oauthenticate :only => [:test_request]
          oauthenticate :strategies => :token, :interactive => false, :only => [:invalidate,:capabilities]
          oauthenticate :strategies => :two_legged, :interactive => false, :only => [:request_token]
          oauthenticate :strategies => :oauth10_request_token, :interactive => false, :only => [:access_token]
          skip_before_filter :verify_authenticity_token, :only=>[:request_token, :access_token, :invalidate, :test_request, :token]
        end
      end

      def request_token
        @token = current_client_application.create_request_token params
        if @token
          render :text => @token.to_query
        else
          render :nothing => true, :status => 401
        end
      end

      def access_token
        @token = current_token && current_token.exchange!
        if @token
          render :text => @token.to_query
        else
          render :nothing => true, :status => 401
        end
      end

      def token
        @client_application = ClientApplication.find_by_key! params[:client_id]
        if @client_application.secret != params[:client_secret]
          oauth2_error "invalid_client"
          return
        end
        # older drafts used none for client_credentials
        params[:grant_type] = 'client_credentials' if params[:grant_type] == 'none'
        logger.info "grant_type=#{params[:grant_type]}"
        if ["authorization_code", "password", "client_credentials"].include?(params[:grant_type])
          send "oauth2_token_#{params[:grant_type].underscore}"
        else
          oauth2_error "unsupported_grant_type"
        end
      end

      def test_request
        render :text => params.collect{|k,v|"#{k}=#{v}"}.join("&")
      end

      def authorize
        if params[:oauth_token]
          @token = ::RequestToken.find_by_token! params[:oauth_token]
          oauth1_authorize
        else
          # XXX oauth2
          if request.post?
            if params[:scope].empty?
              params[:scope] = "http://#{request.host}/scopes/all_access.json"
            end
            @authorizer = OAuth::Provider::Authorizer.new current_person, user_authorizes_token_without_capabilities?, params
            redirect_to @authorizer.redirect_uri
          else
            @client_application = ClientApplication.find_by_key! params[:client_id]
            render :action => "oauth2_authorize"
          end
        end
      end

      def revoke
        @token = current_person.tokens.find_by_token! params[:token]
        if @token
          @token.invalidate!
          flash[:notice] = "You've revoked the token for #{@token.client_application.name}"
        end
        redirect_to oauth_clients_url
      end

      # Invalidate current token
      def invalidate
        current_token.invalidate!
        head :status=>410
      end

      # Capabilities of current_token
      def capabilities
        if current_token.respond_to?(:capabilities)
          @capabilities=current_token.capabilities
        else
          @capabilities={:invalidate=>url_for(:action=>:invalidate)}
        end

        respond_to do |format|
          format.json {render :json=>@capabilities}
          format.xml {render :xml=>@capabilities}
        end
      end

      protected

      def oauth1_authorize
        unless @token
          render :action=>"authorize_failure"
          return
        end

        unless @token.invalidated?
          if request.post?
            if user_authorizes_token?
              @token.authorize!(current_person)
              callback_url  = @token.oob? ? @token.client_application.callback_url : @token.callback_url
              @redirect_url = URI.parse(callback_url) unless callback_url.blank?

              unless @redirect_url.to_s.blank?
                @redirect_url.query = @redirect_url.query.blank? ?
                                      "oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}" :
                                      @redirect_url.query + "&oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
                redirect_to @redirect_url.to_s
              else
                render :action => "authorize_success"
              end
            else
              @token.invalidate!
              render :action => "authorize_failure"
            end
          end
        else
          render :action => "authorize_failure"
        end
      end


      # http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.1
      def oauth2_token_authorization_code
        @verification_code =  @client_application.oauth2_verifiers.find_by_token params[:code]
        unless @verification_code
          oauth2_error
          return
        end
        if @verification_code.redirect_url != params[:redirect_uri]
          oauth2_error
          return
        end
        @token = @verification_code.exchange!
        render :json=>@token
      end

      # http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.2
      def oauth2_token_password
        @user = authenticate_user( params[:username], params[:password])
        unless @user
          oauth2_error
          return
        end
        @token = Oauth2Token.create :client_application=>@client_application, :person=>@user, :scope=>params[:scope]
        render :json=>@token
      end

      # should authenticate and return a user if valid password. Override in your own controller
      def authenticate_user(username,password)
        User.authenticate(username,password)
      end

      # autonomous authorization which creates a token for client_applications user
      def oauth2_token_client_credentials
        @token = Oauth2Token.create :client_application=>@client_application, :person=>@client_application.person, :scope=>params[:scope]
        render :json=>@token
      end

      # Override this to match your authorization page form
      def user_authorizes_token_without_capabilities?
        params[:authorize] == '1'
      end

      def user_authorizes_token?
        token_authorized = false
        @token.capabilities.each do |capability|
          unless params[:capabilities].has_value?(capability.id.to_s)
            capability.invalidate!
          else
            token_authorized = true
          end
        end
        token_authorized
      end

      def oauth2_error(error="invalid_grant")
        render :json=>{:error=>error}.to_json
      end

    end
  end
end
