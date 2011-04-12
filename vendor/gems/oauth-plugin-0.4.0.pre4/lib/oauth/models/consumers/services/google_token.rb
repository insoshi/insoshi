require 'portablecontacts'

class GoogleToken < ConsumerToken
  GOOGLE_SETTINGS={
    :site=>"https://www.google.com", 
    :request_token_path => "/accounts/OAuthGetRequestToken",
    :authorize_path => "/accounts/OAuthAuthorizeToken",
    :access_token_path => "/accounts/OAuthGetAccessToken",
  }
  
  def self.consumer
    @consumer||=create_consumer
  end 
  
  def self.create_consumer(options={})
    OAuth::Consumer.new credentials[:key],credentials[:secret],GOOGLE_SETTINGS.merge(options)
  end
    
  def self.get_request_token(callback_url, scope=nil)
    consumer.get_request_token({:oauth_callback=>callback_url}, :scope=>scope||credentials[:scope]||"http://www-opensocial.googleusercontent.com/api/people")
  end
  
  def portable_contacts
    @portable_contacts||= PortableContacts::Client.new "http://www-opensocial.googleusercontent.com/api/people", client
  end
    
end