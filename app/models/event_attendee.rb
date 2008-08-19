class EventAttendee < ActiveRecord::Base
  belongs_to :person
  belongs_to :event
  validates_uniqueness_of :person_id, :scope => :event_id
end
