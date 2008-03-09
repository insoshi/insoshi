class TopicEvent < Event
  belongs_to :topic, :foreign_key => "instance_id"
end