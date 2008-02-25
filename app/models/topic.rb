class Topic < ActiveRecord::Base
  belongs_to :forum, :counter_cache => true
  belongs_to :person
  has_many :posts, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 255
end
