class WallCommentEvent < Event
  belongs_to :comment, :class_name => "WallComment",
                       :foreign_key => "instance_id"
end