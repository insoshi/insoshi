module Oauth
  module Controllers
    module ConsumerController
      def self.included(controller)
        controller.class_eval do  
          before_filter :load_consumer, :except=>:index
          skip_before_filter :verify_authenticity_token,:only=>:callback
        end
      end
      
      def index
        @consumer_tokens=ConsumerToken.all :conditions=>{:user_id=>current_user.id}
        # The services the user hasn't already connected to
        @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
      end      
      
      # creates request token and redirects on to oauth provider's auth page
      # If user is already connected it displays a page with an option to disconnect and redo
      def show
        unless @token
          if @consumer.ancestors.include?(Oauth2Token)
            request_url = callback2_oauth_consumer_url(params[:id]) + '?' + request.query_string
            redirect_to @consumer.authorize_url(request_url)
          else
            request_url = callback_oauth_consumer_url(params[:id]) + '?' + request.query_string
            @request_token = @consumer.get_request_token(request_url)
            session[@request_token.token]=@request_token.secret
            if @request_token.callback_confirmed?
              redirect_to @request_token.authorize_url
            else
              redirect_to(@request_token.authorize_url + "&oauth_callback=#{callback_oauth_consumer_url(params[:id])}")
            end
          end
        end
      end
      
      def callback2
        @token = @consumer.access_token(current_user,params[:code], callback2_oauth_consumer_url(params[:id]))
        logger.info @token.inspect
        if @token
          # Log user in
          if logged_in?
            flash[:notice] = "#{params[:id].humanize} was successfully connected to your account"
          else
            self.current_user = @token.user 
            flash[:notice] = "You logged in with #{params[:id].humanize}"
          end
          go_back
        else
          flash[:error] = "An error happened, please try connecting again"
          redirect_to oauth_consumer_url(params[:id])
        end

      end

      def callback
        logger.info "CALLBACK"
        @request_token_secret=session[params[:oauth_token]]
        if @request_token_secret
          @token=@consumer.find_or_create_from_request_token(current_user,params[:oauth_token],@request_token_secret,params[:oauth_verifier])
          session[params[:oauth_token]] = nil
          if @token
            # Log user in
            if logged_in?
              flash[:notice] = "#{params[:id].humanize} was successfully connected to your account"
            else
              self.current_user = @token.user 
              flash[:notice] = "You logged in with #{params[:id].humanize}"
            end
            go_back
          else
            flash[:error] = "An error happened, please try connecting again"
            redirect_to oauth_consumer_url(params[:id])
          end
        end

      end

      def client
        method = request.method.downcase.to_sym
        path = "/#{params[:endpoint]}?#{request.query_string}"
        if consumer_credentials[:expose]
          if @token
            oauth_response = @token.client.send(method, path)
            if oauth_response.is_a? Net::HTTPRedirection
              # follow redirect
              oauth_response = @token.client.send(method, oauth_response['Location'])
            end

            render :text => oauth_response.body
          else
            render :text => "Token needed.", :status => 403
          end
        else
          render :text => "Not allowed", :status => 403
        end
      end

      def destroy
        throw RecordNotFound unless @token
        @token.destroy
        if params[:commit]=="Reconnect"
          redirect_to oauth_consumer_url(params[:id])
        else
          flash[:notice] = "#{params[:id].humanize} was successfully disconnected from your account"
          
          go_back
        end
      end

      protected
      
      # Override this in your controller to decide where you want to redirect user to after callback is finished.
      def go_back
        redirect_to root_url
      end
      
      def consumer_credentials
        OAUTH_CREDENTIALS[consumer_key]
      end
      
      def consumer_key
        @consumer_key ||= params[:id].to_sym
      end
      
      def load_consumer
        throw RecordNotFound unless OAUTH_CREDENTIALS.include?(consumer_key)
        deny_access! unless logged_in? || consumer_credentials[:allow_login]
        @consumer="#{consumer_key.to_s.camelcase}Token".constantize
        @token=@consumer.find(:first, :conditions=>{:user_id=>current_user.id.to_s}) if logged_in?
      end
      
      # Override this in you controller to deny user or redirect to login screen.
      def deny_access!
        head 401
      end
      
    end
  end
end
