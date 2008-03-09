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

class Event < ActiveRecord::Base
  belongs_to :person
  attr_accessor :instance
  
  def instance=(obj)
    self.instance_id = obj.id
  end
end
