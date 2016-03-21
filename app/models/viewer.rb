# == Schema Information
#
# Table name: viewers
#
#  id         :integer          not null, primary key
#  topic_id   :integer
#  person_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Viewer < ActiveRecord::Base
  belongs_to :topic
  belongs_to :person
end
