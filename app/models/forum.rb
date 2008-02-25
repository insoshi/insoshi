class Forum < ActiveRecord::Base
  has_many :topics, :dependent => :destroy
  has_many :posts, :through => :topics
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 1000
end
