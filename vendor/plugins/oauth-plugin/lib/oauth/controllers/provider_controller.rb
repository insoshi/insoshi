module OAuth
  module Controllers
   
    module ProviderController
      def self.included(controller)
        controller.class_eval do
          before_filter :login_required, :only => [:authorize,:revoke]
          before_filter :login_or_oauth_required, :only => [:test_request]
          before_filter :oauth_required, :only => [:invalidate,:capabilities]
          before_filter :verify_oauth_consumer_signature, :only => [:request_token]
          before_filter :verify_oauth_request_token, :only => [:access_token]
          skip_before_filter :verify_authenticity_token, :only=>[:request_token, :access_token, :invalidate, :test_request]
        end
      end
      
      def request_token
        @token = current_client_application.create_request_token
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

      def test_request
        render :text => params.collect{|k,v|"#{k}=#{v}"}.join("&")
      end

      def authorize
        @token = ::RequestToken.find_by_token params[:oauth_token]
        unless @token
          render :action=>"authorize_failure"
          return
        end
        
        unless @token.invalidated?    
          if request.post? 
            if user_authorizes_token?
              @token.authorize!(current_user)
              if @token.oauth10?
                @redirect_url = params[:oauth_callback] || @token.client_application.callback_url
              else
                @redirect_url = @token.oob? ? @token.client_application.callback_url : @token.callback_url
              end
              
              if @redirect_url
                if @token.oauth10?
                  redirect_to "#{@redirect_url}?oauth_token=#{@token.token}"
                else
                  redirect_to "#{@redirect_url}?oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
                end
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

      def revoke
        @token = current_user.tokens.find_by_token params[:token]
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
      
      # Override this to match your authorization page form
      def user_authorizes_token?
        params[:authorize] == '1'
      end
    end
  end
end