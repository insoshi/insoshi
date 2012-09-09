# == Schema Information
# Schema version: 20090216032013
#
# Table name: activities
#
#  id         :integer(4)      not null, primary key
#  public     :boolean(1)      
#  item_id    :integer(4)      
#  person_id  :integer(4)      
#  item_type  :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Activity < ActiveRecord::Base
  extend PreferencesHelper
  belongs_to :person
  belongs_to :group
  belongs_to :item, :polymorphic => true
  has_many :feeds, :dependent => :destroy
  
  GLOBAL_FEED_SIZE = 10

  module Scopes

    def _person_active
      if global_prefs.email_verifications
        {"people.deactivated" => false, "people.email_verified" => true}
      else
        {"people.deactivated" => false}
      end
    end

    def global_feed
      joins(:person).
      where(_person_active).
      order('activities.created_at DESC').
      limit(GLOBAL_FEED_SIZE)
    end

    def group_feed(group_id)
      global_feed.where(:group_id => group_id)
    end

    def exchange_feed
      where(:item_type => "Exchange").
      order('activities.created_at DESC').
      limit(GLOBAL_FEED_SIZE)
    end

  end

  extend Scopes

end
