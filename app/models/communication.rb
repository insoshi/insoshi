# == Schema Information
#
# Table name: communications
#
#  id                   :integer          not null, primary key
#  subject              :string(255)
#  content              :text
#  sender_id            :integer
#  recipient_id         :integer
#  sender_deleted_at    :datetime
#  sender_read_at       :datetime
#  recipient_deleted_at :datetime
#  recipient_read_at    :datetime
#  replied_at           :datetime
#  type                 :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  parent_id            :integer
#  conversation_id      :integer
#

class Communication < ActiveRecord::Base
end
