class Forum < ActiveRecord::Base
  has_many :topics, :order => "created_at DESC", :dependent => :destroy
  has_many :posts, :through => :topics
  
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 1000, :allow_nil => true
end
