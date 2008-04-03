# == Schema Information
# Schema version: 15
#
# Table name: activities
#
#  id         :integer         not null, primary key
#  public     :boolean         
#  item_id    :integer         
#  person_id  :integer         
#  item_type  :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Activity < ActiveRecord::Base
  belongs_to :person
  belongs_to :item, :polymorphic => true
  has_many :feeds
end
