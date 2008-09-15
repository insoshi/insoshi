# == Schema Information
# Schema version: 28
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
  belongs_to :group
  belongs_to :item, :polymorphic => true
  has_many :feeds, :dependent => :destroy
  
  GLOBAL_FEED_SIZE = 10

  # Return a feed drawn from all activities.
  # The fancy SQL is to keep inactive people out of feeds.
  # It's hard to do that entirely, but this way deactivated users 
  # won't be the person in "<person> has <done something>".
  #
  # This is especially useful for sites that require email verifications.
  # Their 'connected with admin' item won't show up until they verify.
  def self.global_feed
    find(:all, 
         :joins => "INNER JOIN people p ON activities.person_id = p.id",
         :conditions => [%(p.deactivated = ? AND
                           (p.email_verified IS NULL OR p.email_verified = ?)), 
                         false, true], 
         :order => 'activities.created_at DESC',
         :limit => GLOBAL_FEED_SIZE)
  end
end
