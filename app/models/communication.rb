# == Schema Information
# Schema version: 25
#
# Table name: communications
#
#  id                   :integer         not null, primary key
#  subject              :string(255)     
#  content              :text            
#  parent_id            :string(255)     
#  sender_id            :integer         
#  recipient_id         :integer         
#  sender_deleted_at    :datetime        
#  sender_read_at       :datetime        
#  recipient_deleted_at :datetime        
#  recipient_read_at    :datetime        
#  replied_at           :datetime        
#  type                 :string(255)     
#  created_at           :datetime        
#  updated_at           :datetime        
#

class Communication < ActiveRecord::Base
end
