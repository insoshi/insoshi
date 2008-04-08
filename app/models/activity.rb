# == Schema Information
# Schema version: 15
#
# Table name: activities
#
#  id         :integer(11)     not null, primary key
#  public     :boolean(1)      
#  item_id    :integer(11)     
#  person_id  :integer(11)     
#  item_type  :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Activity < ActiveRecord::Base
  belongs_to :person
  belongs_to :item, :polymorphic => true
  has_many :feeds
end
