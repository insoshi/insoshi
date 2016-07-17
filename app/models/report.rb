# == Schema Information
#
# Table name: reports
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  record     :string(255)
#  person_id  :integer
#  group_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Report < ActiveRecord::Base
  belongs_to :person
  belongs_to :group

  scope :offers, -> { where(type: 'OfferReport') }
  scope :reqs, -> { where(type: 'ReqReport') }
  scope :memberships, -> { where(type: 'MembershipReport') }
end
