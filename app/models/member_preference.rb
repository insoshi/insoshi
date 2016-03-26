# == Schema Information
#
# Table name: member_preferences
#
#  id                  :integer          not null, primary key
#  req_notifications   :boolean          default(TRUE)
#  forum_notifications :boolean          default(TRUE)
#  membership_id       :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class MemberPreference < ActiveRecord::Base
  belongs_to :membership
end
