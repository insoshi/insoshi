require 'oauth/consumer'
require File.join(File.dirname(__FILE__), 'simple_client')

module Oauth
  module Models
    module Consumers
      module Token
        def self.included(model)
          model.class_eval do
            validates_presence_of :user, :token
          end

          model.send(:include, InstanceMethods)
          model.send(:extend, ClassMethods)

        end
        
        module ClassMethods
          
          def service_name
            @service_name||=self.to_s.underscore.scan(/^(.*?)(_token)?$/)[0][0].to_sym
          end
          
          def consumer
            options = credentials[:options] || {}
            @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],options
          end

          def get_request_token(callback_url)
            consumer.get_request_token(:oauth_callback=>callback_url)
          end

          def find_or_create_from_request_token(user,token,secret,oauth_verifier)
            request_token=OAuth::RequestToken.new consumer,token,secret
            options={}
            options[:oauth_verifier]=oauth_verifier if oauth_verifier
            access_token=request_token.get_access_token options
            find_or_create_from_access_token user, access_token
          end
          
          def find_or_create_from_access_token(user,access_token)
            secret = access_token.respond_to?(:secret) ? access_token.secret : nil
            if user
              token = self.find_or_initialize_by_user_id_and_token(user.id, access_token.token)
            else
              token = self.find_or_initialize_by_token(access_token.token)
            end
            
            # set or update the secret
            token.secret = secret
            token.save! if token.new_record? or token.changed?

            token
          end
          
          def build_user_from_token
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

          def simple_client
            @simple_client||=SimpleClient.new client
          end
          
          # Override this to return user data from service
          def params_for_user
            {}
          end
          
          def create_user
            self.user ||= begin
              User.new params_for_user
              user.save(:validate=>false)
            end
          end  
          
        end
      end
    end
  end
end
