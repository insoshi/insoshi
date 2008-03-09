class ConnectionEvent < Event
  belongs_to :conn, :class_name => "Connection", :foreign_key => "instance_id"
end