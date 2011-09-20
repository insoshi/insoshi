require 'oauth2'
class Oauth2Token < ConsumerToken
  
  def self.consumer
    @consumer||=create_consumer
  end 
  
  def self.create_consumer(options={})
    @consumer||=OAuth2::Client.new credentials[:key],credentials[:secret],credentials[:options]
  end
    
  def self.authorize_url(callback_url)
    options = {:redirect_uri=>callback_url}
    options[:scope] = credentials[:scope] if credentials[:scope].present?
    consumer.web_server.authorize_url(options)
  end
  
  def self.access_token(user, code, redirect_uri)
    access_token = consumer.web_server.get_access_token(code, :redirect_uri => redirect_uri)
    find_or_create_from_access_token user, access_token
  end
  
  def client
    @client ||= OAuth2::AccessToken.new self.class.consumer, token
  end
    
end