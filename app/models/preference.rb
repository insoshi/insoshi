# == Schema Information
# Schema version: 28
#
# Table name: preferences
#
#  id                  :integer(11)     not null, primary key
#  domain              :string(255)     default(""), not null
#  smtp_server         :string(255)     default(""), not null
#  email_notifications :boolean(1)      not null
#  email_verifications :boolean(1)      not null
#  created_at          :datetime        
#  updated_at          :datetime        
#  analytics           :text            
#  server_name         :string(255)     
#  app_name            :string(255)     
#  about               :text            
#  demo                :boolean(1)      
#

class Preference < ActiveRecord::Base
  attr_accessor :twitter_password
  attr_accessible :app_name, :server_name, :domain, :smtp_server, 
                  :exception_notification,
                  :email_notifications, :email_verifications, :analytics,
                  :about, :demo, :whitelist, :gmail, :registration_notification,
                  :practice, :steps, :questions, :memberships, :contact,
                  :twitter_name, :twitter_password

  validates_presence_of :domain,       :if => :using_email?
  validates_presence_of :smtp_server,  :if => :using_email?
  
  before_save :encrypt_twitter_password

  # Can we send mail with the present configuration?
  def can_send_email?
    not (domain.blank? or smtp_server.blank?)
  end
  
  private
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
  
    def using_email?
      email_notifications? or email_verifications?
    end
end
