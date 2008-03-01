class Topic < ActiveRecord::Base
  
  MAX_NAME = 70
  
  belongs_to :forum, :counter_cache => true
  belongs_to :person
  has_many :posts, :order => :created_at, :dependent => :destroy,
                   :class_name => "ForumPost"
  
  validates_presence_of :name, :forum, :person
  validates_length_of :name, :maximum => MAX_NAME
end
