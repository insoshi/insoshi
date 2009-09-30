require 'oauth'
class ClientApplication < ActiveRecord::Base
  belongs_to :user
  has_many :tokens, :class_name => "OauthToken"
  validates_presence_of :name, :url, :key, :secret
  validates_uniqueness_of :key
  before_validation_on_create :generate_keys

  validates_format_of :url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  validates_format_of :support_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true
  validates_format_of :callback_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true

  attr_accessor :token_callback_url
  
  def self.find_token(token_key)
    token = OauthToken.find_by_token(token_key, :include => :client_application)
    if token && token.authorized?
      token
    else
      nil
    end
  end
  
  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      logger.info "ERROR"+e.to_s
      false
    end
  end
  
  def oauth_server
    @oauth_server ||= OAuth::Server.new("http://your.site")
  end
  
  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end
    
  def create_request_token
    RequestToken.create :client_application => self,:callback_url=>self.token_callback_url
  end
  
protected
  
  def generate_keys
    oauth_client = oauth_server.generate_consumer_credentials
    self.key = oauth_client.key[0,20]
    self.secret = oauth_client.secret[0,40]
  end
end
