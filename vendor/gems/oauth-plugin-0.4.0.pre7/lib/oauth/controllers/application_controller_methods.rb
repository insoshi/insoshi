module OAuth
  module Controllers

    module ApplicationControllerMethods

      def self.included(controller)
        controller.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def oauthenticate(options={})
          filter_options = {}
          filter_options[:only]   = options.delete(:only) if options[:only]
          filter_options[:except] = options.delete(:except) if options[:except]
          before_filter Filter.new(options), filter_options
        end
      end

      class Filter
        def initialize(options={})
          @options={
              :interactive=>true,
              :strategies => [:token,:two_legged]
            }.merge(options)
          @strategies = Array(@options[:strategies])
          @strategies << :interactive if @options[:interactive]
        end

        def filter(controller)
          Authenticator.new(controller,@strategies).allow?
        end
      end

      class Authenticator
        attr_accessor :controller, :strategies, :strategy
        def initialize(controller,strategies)
          @controller = controller
          @strategies = strategies
        end

        def allow?
          if @strategies.include?(:interactive) && interactive
            true
          elsif !(@strategies & env["oauth.strategies"].to_a).empty?
            @controller.send :current_person=, token.person if token
            true
          else
            if @strategies.include?(:interactive)
              controller.send :access_denied
            else
              controller.send :invalid_oauth_response
            end
          end
        end

        def oauth20_token
           env["oauth.version"]==2 && env["oauth.token"]
        end

        def oauth10_token
          env["oauth.version"]==1 && env["oauth.token"]
        end

        def oauth10_request_token
          oauth10_token && oauth10_token.is_a?(::RequestToken) ? oauth10_token : nil
        end

        def oauth10_access_token
          oauth10_token && oauth10_token.is_a?(::AccessToken) ? oauth10_token : nil
        end

        def token
          oauth20_token || oauth10_access_token || nil
        end

        def client_application
          env["oauth.version"]==1 && env["oauth.client_application"] || oauth20_token.try(:client_application)
        end

        def two_legged
           env["oauth.version"]==1 && client_application
        end

        def interactive
          @controller.send :logged_in?
        end

        def env
          request.env
        end

        def request
          controller.send :request
        end

      end

      protected

      def current_token
        request.env["oauth.token"]
      end

      def current_client_application
        request.env["oauth.version"]==1 && request.env["oauth.client_application"] || current_token.try(:client_application)
      end

      def oauth?
        current_token
      end

      # use in a before_filter. Note this is for compatibility purposes. Better to use oauthenticate now
      def oauth_required
        Authenticator.new(self,[:oauth10_access_token]).allow?
      end

      # use in before_filter. Note this is for compatibility purposes. Better to use oauthenticate now
      def login_or_oauth_required
        Authenticator.new(self,[:oauth10_access_token,:interactive]).allow?
      end

      def invalid_oauth_response(code=401,message="Invalid OAuth Request")
        render :text => {:error => message}.to_json, :status => code
        false
      end

      # override this in your controller
      def access_denied
        head 401
      end

    end
  end
end
