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
  attr_accessible :domain, :smtp_server, :email_notifications

  validates_presence_of :domain, :if => :email_notifications
  validates_presence_of :smtp_server,  :if => :email_notifications  
end
