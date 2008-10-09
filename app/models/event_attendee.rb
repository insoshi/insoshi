# == Schema Information
# Schema version: 20080916002106
#
# Table name: event_attendees
#
#  id        :integer(4)      not null, primary key
#  person_id :integer(4)      
#  event_id  :integer(4)      
#

class EventAttendee < ActiveRecord::Base
  include ActivityLogger

  belongs_to :person
  belongs_to :event, :counter_cache => true
  validates_uniqueness_of :person_id, :scope => :event_id

  after_create :log_activity

  def log_activity
    add_activities(:item => self, :person => self.person)
  end

end
