class BlogPostComment < Comment
  belongs_to :person
  belongs_to :post, :counter_cache => true
  validates_presence_of :post
end