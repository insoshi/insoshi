class ActivityStatus < ActiveRecord::Base
	validates_presence_of	:name
	validates_length_of     :name,  :maximum => 100
	validates_length_of     :description,  :maximum => 255

	has_many :people, :dependent => :restrict

	default_scope :order => 'name ASC'
end
