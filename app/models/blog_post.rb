class BlogPost < Post
  belongs_to :blog
  
  validates_presence_of :body
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
end
