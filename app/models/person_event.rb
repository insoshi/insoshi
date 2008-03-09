class PersonEvent < Event
  belongs_to :person, :foreign_key => "instance_id"
end