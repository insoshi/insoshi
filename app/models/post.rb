class Post < ActiveRecord::Base
  belongs_to :topic, :counter_cache => true
  belongs_to :person, :counter_cache => true
  
  validates_presence_of :body
  validates_length_of :body, :maximum => 1000
end
