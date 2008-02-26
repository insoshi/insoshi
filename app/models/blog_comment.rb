class BlogComment < Comment
  belongs_to :blog
  validates_presence_of :blog
end