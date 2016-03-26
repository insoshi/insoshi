# == Schema Information
#
# Table name: forums
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  description   :text
#  topics_count  :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :integer
#  worldwritable :boolean          default(FALSE)
#

class Forum < ActiveRecord::Base
  attr_accessible :name, :description # XXX these are not used for anything. remove them?
  attr_accessible :worldwritable

  belongs_to :group
  has_many :topics, :order => "updated_at DESC", :dependent => :destroy
  has_many :posts, :through => :topics

  
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 1000, :allow_nil => true
end
