# == Schema Information
# Schema version: 20090216032013
#
# Table name: preferences
#
#  id                                    :integer(4)      not null, primary key
#  domain                                :string(255)     default(""), not null
#  smtp_server                           :string(255)     default(""), not null
#  email_notifications                   :boolean(1)      not null
#  email_verifications                   :boolean(1)      not null
#  created_at                            :datetime        
#  updated_at                            :datetime        
#  analytics                             :text            
#  server_name                           :string(255)     
#  app_name                              :string(255)     
#  about                                 :text            
#  demo                                  :boolean(1)      
#  whitelist                             :boolean(1)      
#  gmail                                 :string(255)     
#  exception_notification                :string(255)     
#  registration_notification             :boolean(1)      
#  practice                              :text            
#  steps                                 :text            
#  questions                             :text            
#  memberships                           :text            
#  contact                               :text            
#  twitter_name                          :string(255)     
#  crypted_twitter_password              :string(255)     
#  twitter_api                           :string(255)     
#  twitter_oauth_consumer_key            :string(255)     
#  crypted_twitter_oauth_consumer_secret :string(255)     
#

class Preference < ActiveRecord::Base
  attr_accessor :twitter_password,
                :twitter_oauth_consumer_secret
  attr_accessible :app_name, :server_name, :domain, :smtp_server, 
                  :exception_notification,
                  :email_notifications, :email_verifications, :analytics,
                  :about, :demo, :whitelist, :gmail, :registration_notification,
                  :practice, :steps, :questions, :memberships, :contact,
                  :twitter_name, :twitter_password, :twitter_api,
                  :group_option,
                  :zipcode_browsing,
                  :blog_feed_url,
                  :twitter_oauth_consumer_key, :twitter_oauth_consumer_secret

  validates_presence_of :domain,       :if => :using_email?
  validates_presence_of :smtp_server,  :if => :using_email?
  validates_presence_of :twitter_api,  :if => :using_twitter?
  
  before_save :encrypt_twitter_password
  before_save :encrypt_twitter_oauth_consumer_secret

  before_validation :set_default_twitter_api_if_using_twitter

  # Can we send mail with the present configuration?
  def can_send_email?
    not (domain.blank? or smtp_server.blank?)
  end

  def plaintext_twitter_password
    decrypt(crypted_twitter_password)
  end

  def plaintext_twitter_oauth_consumer_secret
    decrypt(crypted_twitter_oauth_consumer_secret)
  end

  private
    def decrypt(password)
      Crypto::Key.from_file("#{RAILS_ROOT}/rsa_key").decrypt(password)
    end

    def self.encrypt(password)
      Crypto::Key.from_file("#{RAILS_ROOT}/rsa_key.pub").encrypt(password)
    end
  
    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.encrypt(password)
    end

    def encrypt_twitter_password
      return if twitter_password.blank?
      self.crypted_twitter_password = encrypt(twitter_password)
    end

    def encrypt_twitter_oauth_consumer_secret
      return if twitter_oauth_consumer_secret.blank?
      self.crypted_twitter_oauth_consumer_secret = encrypt(twitter_oauth_consumer_secret)
    end

    def set_default_twitter_api_if_using_twitter
      self.twitter_api = 'twitter.com' if self.twitter_api.blank?
    end
 
    def using_twitter?
      twitter_name?
    end

    def using_email?
      email_notifications? or email_verifications?
    end
end
