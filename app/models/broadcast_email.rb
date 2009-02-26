# == Schema Information
# Schema version: 20090216032013
#
# Table name: broadcast_emails
#
#  id         :integer(4)      not null, primary key
#  subject    :string(255)     
#  message    :text            
#  created_at :datetime        
#  updated_at :datetime        
#

class BroadcastEmail < ActiveRecord::Base
end
