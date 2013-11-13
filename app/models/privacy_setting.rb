class PrivacySetting < ActiveRecord::Base
  belongs_to :group

  attr_accessible :viewable_reqs
  attr_accessible :viewable_offers
  attr_accessible :viewable_forum
  attr_accessible :viewable_members
end
