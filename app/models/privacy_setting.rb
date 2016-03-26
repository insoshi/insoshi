# == Schema Information
#
# Table name: privacy_settings
#
#  id               :integer          not null, primary key
#  group_id         :integer
#  viewable_reqs    :boolean          default(TRUE)
#  viewable_offers  :boolean          default(TRUE)
#  viewable_forum   :boolean          default(TRUE)
#  viewable_members :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PrivacySetting < ActiveRecord::Base
  belongs_to :group

  attr_accessible :viewable_reqs
  attr_accessible :viewable_offers
  attr_accessible :viewable_forum
  attr_accessible :viewable_members
end
