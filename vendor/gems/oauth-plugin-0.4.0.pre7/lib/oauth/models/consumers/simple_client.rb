require 'json'
module Oauth
  module Models
    module Consumers
      # This is just a simple
      class SimpleClient
        attr_reader :token
  
        def initialize(token)
          @token = token
        end
  
  
        def put(path,params={})
          parse(token.put(path,params, {'Accept' => 'application/json'}))
        end

        def delete(path)
          parse(token.delete(path, {'Accept' => 'application/json'}))
        end

        def post(path,params={})
          parse(token.post(path,params, {'Accept' => 'application/json'}))
        end

        def get(path)
          parse(token.get(path, {'Accept' => 'application/json'}))
        end

        protected

        def parse(response)
          return false unless response
          if ["200","201"].include? response.code
            unless response.body.blank?
              JSON.parse(response.body)
            else
              true
            end
          else
            logger.debug "Got Response code: #{response.code}"
            false
          end
          
        end
        
      end
    end
  end
end