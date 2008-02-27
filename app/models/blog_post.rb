class BlogPost < Post
  belongs_to :blog
  has_many :comments, :class_name => "BlogPostComment",
                      :order => :created_at
  
  validates_presence_of :title, :body
  validates_length_of :title, :maximum => MAX_STRING_LENGTH
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
end
