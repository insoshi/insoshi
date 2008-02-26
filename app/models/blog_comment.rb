class BlogComment < Comment
  belongs_to :blog, :counter_cache => true
  validates_presence_of :blog
end