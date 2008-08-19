class Event < ActiveRecord::Base
  belongs_to :person
  has_many :event_attendees
  has_many :attendees, :through => :event_attendees, :source => :person

  validates_presence_of :title, :start_time, :person

  def attend(person)
    self.event_attendees.create!(:person => person)
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def unattend(person)
    if event_attendee = self.event_attendees.find_by_person_id(person)
        event_attendee.destroy
    else
      nil
    end
  end

  def attending?(person)
    self.attendee_ids.include?(person[:id])
  end
end
