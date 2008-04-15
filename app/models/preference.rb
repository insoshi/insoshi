# == Schema Information
# Schema version: 16
#
# Table name: preferences
#
#  id                  :integer(11)     not null, primary key
#  email_domain        :string(255)     
#  smtp_server         :string(255)     
#  email_notifications :boolean(1)      
#  created_at          :datetime        
#  updated_at          :datetime        
#

class Preference < ActiveRecord::Base
  validates_presence_of :email_domain, :if => :email_notifications
  validates_presence_of :smtp_server,  :if => :email_notifications  
  
  # Return true if we want the system to send out email validations.
  # This is a stub for now; it's true if email_notifications is true.
  # TODO: add finer-grained preferences
  def email_validation?
    email_notifications
  end
end
