class ForumPost < Post
  belongs_to :topic,  :counter_cache => true
  belongs_to :person, :counter_cache => true
  
  validates_presence_of :body, :topic, :person
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
end
