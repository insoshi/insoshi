class TopicEvent < Event
  belongs_to :topic, :class_name => "Topic", :foreign_key => "instance_id"
end