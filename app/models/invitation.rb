# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  group_id    :integer
#  person_id   :integer
#  accepted_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Invitation < ActiveRecord::Base
  extend PreferencesHelper

  belongs_to :person
  belongs_to :group

  def accept
    if accepted_at.nil?
      touch :accepted_at
      Membership.create!(person: person, group: group, status: Membership::ACCEPTED)
      if Invitation.global_prefs.email_notifications?
        after_transaction { PersonMailerQueue.invitation_accepted(self) }
      end
    end
  end
end
