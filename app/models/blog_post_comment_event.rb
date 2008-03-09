class BlogPostCommentEvent < Event
  belongs_to :comment, :class_name => "BlogPostComment",
                       :foreign_key => "instance_id"
end