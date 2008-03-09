# == Schema Information
# Schema version: 10
#
# Table name: events
#
#  id          :integer(11)     not null, primary key
#  person_id   :integer(11)     
#  instance_id :integer(11)     
#  type        :string(255)     
#  created_at  :datetime        
#  updated_at  :datetime        
#

class ConnectionEvent < Event
  belongs_to :conn, :class_name => "Connection", :foreign_key => "instance_id"
end
