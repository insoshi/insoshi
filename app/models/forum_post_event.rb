class ForumPostEvent < Event
  belongs_to :post, :class_name => "ForumPost", :foreign_key => "instance_id"
end