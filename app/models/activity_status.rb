# == Schema Information
#
# Table name: activity_statuses
#
#  id          :integer          not null, primary key
#  name        :string(100)      not null
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ActivityStatus < ActiveRecord::Base
	validates_presence_of	:name
	validates_length_of     :name,  :maximum => 100
	validates_length_of     :description,  :maximum => 255

	has_many :people, :dependent => :restrict

	default_scope :order => 'name ASC'
end
