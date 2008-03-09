class PersonEvent < Event
  belongs_to :person, :class_name => "Person", :foreign_key => "instance_id"
end