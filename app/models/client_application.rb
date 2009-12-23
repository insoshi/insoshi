# == Schema Information
# Schema version: 20090216032013
#
# Table name: client_applications
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)     
#  url          :string(255)     
#  support_url  :string(255)     
#  callback_url :string(255)     
#  key          :string(50)      
#  secret       :string(50)      
#  person_id    :integer(4)      
#  created_at   :datetime        
#  updated_at   :datetime        
#

require 'oauth'

class ClientApplication < ActiveRecord::Base
  extend PreferencesHelper 

  belongs_to :person
  has_many :tokens,:class_name=>"OauthToken"
  validates_presence_of :name,:url,:key,:secret
  validates_uniqueness_of :key
  before_validation_on_create :generate_keys
  
  validates_format_of :url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  validates_format_of :support_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true
  validates_format_of :callback_url, :with => /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i, :allow_blank=>true

  attr_accessor :token_callback_url

  def self.find_token(token_key)
    token=OauthToken.find_by_token(token_key, :include => :client_application)
    logger.info "XXX Token key: #{token_key}"
    logger.info "Loaded #{token.token} which was authorized by (person_id=#{token.person_id}) on the #{token.authorized_at}"
    if token && token.authorized?
      token
    else
      nil
    end
  end
  
  def self.verify_request(request, options = {}, &block)
    begin
      signature=OAuth::Signature.build(request,options,&block)
      logger.info "Signature Base String: #{signature.signature_base_string}"
      logger.info "Consumer: #{signature.send :consumer_key}"
      logger.info "Token: #{signature.send :token}"
      return false unless OauthNonce.remember(signature.request.nonce,signature.request.timestamp)
      value=signature.verify
      logger.info "Signature verification returned: #{value.to_s}"
      value
    rescue OAuth::Signature::UnknownSignatureMethod=>e
      logger.info "ERROR"+e.to_s
     false
    end
  end
  
  def oauth_server
    @oauth_server||=OAuth::Server.new( "http://" + ClientApplication.global_prefs.server_name )
  end
  
  def credentials
    @oauth_client||=OAuth::Consumer.new key,secret
  end
    
  def create_request_token
    RequestToken.create :client_application => self, :callback_url => self.token_callback_url
  end
  
  protected
  
  def generate_keys
    oauth_client = oauth_server.generate_consumer_credentials
    self.key = oauth_client.key[0,20]
    self.secret = oauth_client.secret[0,40]
  end
end
