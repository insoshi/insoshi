class Event < ActiveRecord::Base

  MAX_DESCRIPTION_LENGTH = MAX_STRING_LENGTH
  MAX_TITLE_LENGTH = MAX_STRING_LENGTH

  belongs_to :person
  has_many :event_attendees
  has_many :attendees, :through => :event_attendees, :source => :person

  validates_presence_of :title, :start_time, :person
  validates_length_of :title, :maximum => MAX_TITLE_LENGTH
  validates_length_of :description, :maximum => MAX_DESCRIPTION_LENGTH, :allow_blank => true

  named_scope :user_events, lambda { |person| { :conditions => { } } }
  named_scope :monthly_events, 
              lambda { |date| { :conditions => ['start_time >= ? and start_time <= ?', 
                                                date.beginning_of_month, date.end_of_month] } }
  named_scope :daily_events, 
              lambda { |date| { :conditions => ['start_time >= ? and start_time <= ?', 
                                                date.beginning_of_day, date.end_of_day] } }
  def validate
    if end_time
      unless start_time <= end_time
        errors.add(:start_time, "can't be later than End Time")
      end
    end
  end
  
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

  def privacy
    
  end
end
