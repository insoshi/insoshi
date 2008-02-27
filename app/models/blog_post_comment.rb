class BlogPostComment < Comment
  belongs_to :commenter, :class_name => "Person", :foreign_key => "commenter"
  belongs_to :post, :counter_cache => true
  validates_presence_of :post
end