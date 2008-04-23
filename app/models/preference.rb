# == Schema Information
# Schema version: 17
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
#

class Preference < ActiveRecord::Base
  attr_accessible :domain, :smtp_server, :email_notifications,
                  :email_verifications, :analytics

  validates_presence_of :domain,       :if => :using_email?
  validates_presence_of :smtp_server,  :if => :using_email?
  
  private
  
    def using_email?
      email_notifications? or email_verifications?
    end
end
