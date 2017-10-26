# == Schema Information
#
# Table name: member_preferences
#
#  id                  :integer          not null, primary key
#  req_notifications   :boolean          default(TRUE)
#  forum_notifications :boolean          default(TRUE)
#  membership_id       :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class MemberPreference < ActiveRecord::Base
  belongs_to :membership
end
