require 'oauth/consumer'
require File.join(File.dirname(__FILE__), 'simple_client')

module Oauth
  module Models
    module Consumers
      module Token
        def self.included(model)
          model.class_eval do
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
            Rails.logger.info "OAUTH_CONSUMER #{consumer.inspect}"
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
            if user
              user.consumer_tokens.first(:conditions=>{:type=>self.to_s,:token=>access_token.token}) ||
                user.consumer_tokens.create!(:type=>self.to_s,:token=>access_token.token, :secret=>access_token.secret)
            else
              ConsumerToken.first( :conditions =>{ :token=>access_token.token,:type=>self.to_s}) ||
                create(:type=>self.to_s,:token=>access_token.token, :secret=>access_token.secret)
            end
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
