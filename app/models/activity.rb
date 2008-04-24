# == Schema Information
# Schema version: 19
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
  
  GLOBAL_FEED_SIZE = 10

  # Return a feed drawn from all activities.
  def self.global_feed
    find(:all, :order => 'created_at DESC', :limit => GLOBAL_FEED_SIZE)
  end
end
