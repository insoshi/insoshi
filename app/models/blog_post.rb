class BlogPost < Post
  belongs_to :blog
  belongs_to :person
  
  validates_presence_of :body, :person
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
end
