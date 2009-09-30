require 'oauth/consumer'
module Oauth
  module Models
    module Consumers
      module Token
        def self.included(model)
          model.class_eval do
            belongs_to :user
            validates_presence_of :user, :token, :secret                      
          end

          model.send(:include, InstanceMethods)
          model.send(:extend, ClassMethods)

        end
        
        module ClassMethods
          
          def service_name
            @service_name||=self.to_s.underscore.scan(/^(.*?)(_token)?$/)[0][0].to_sym
          end
          
          def consumer
            @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],credentials[:options]
          end

          def get_request_token(callback_url)
            consumer.get_request_token(:oauth_callback=>callback_url)
          end

          def create_from_request_token(user,token,secret,oauth_verifier)
            logger.info "create_from_request_token"
            request_token=OAuth::RequestToken.new consumer,token,secret
            access_token=request_token.get_access_token :oauth_verifier=>oauth_verifier
            logger.info self.inspect
            logger.info user.inspect
            create :user_id=>user.id,:token=>access_token.token,:secret=>access_token.secret
          end
          
          protected
          
          def credentials
            @credentials||=OAUTH_CREDENTIALS[service_name]
          end
          
        end
        
        module InstanceMethods
          
          # Main client for interfacing with remote service. Override this to use
          # preexisting library eg. Twitter gem.
          def client
            @client||=OAuth::AccessToken.new self.class.consumer,token,secret
          end
          
        end
      end
    end
  end
end