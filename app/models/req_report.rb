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

class ReqReport < Report; end
