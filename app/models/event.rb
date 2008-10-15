# == Schema Information
# Schema version: 20080916002106
#
# Table name: events
#
#  id                    :integer(4)      not null, primary key
#  title                 :string(255)     default(""), not null
#  description           :string(255)     
#  person_id             :integer(4)      not null
#  start_time            :datetime        not null
#  end_time              :datetime        
#  reminder              :boolean(1)      
#  created_at            :datetime        
#  updated_at            :datetime        
#  event_attendees_count :integer(4)      default(0)
#  privacy               :integer(4)      not null
#

class Event < ActiveRecord::Base
  include ActivityLogger

  attr_accessible :title, :description

  MAX_DESCRIPTION_LENGTH = MAX_STRING_LENGTH
  MAX_TITLE_LENGTH = 40
  PRIVACY = { :public => 1, :contacts => 2 }

  belongs_to :person
  has_many :event_attendees
  has_many :attendees, :through => :event_attendees, :source => :person
  has_many :comments, :as => :commentable, :order => 'created_at DESC'
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy,
                        :conditions => "item_type = 'Event'"
  

  validates_presence_of :title, :start_time, :person, :privacy
  validates_length_of :title, :maximum => MAX_TITLE_LENGTH
  validates_length_of :description, :maximum => MAX_DESCRIPTION_LENGTH, :allow_blank => true

  named_scope :person_events, 
              lambda { |person| { :conditions => ["person_id = ? OR (privacy = ? OR (privacy = ? AND (person_id IN (?))))", 
                                                  person.id,
                                                  PRIVACY[:public], 
                                                  PRIVACY[:contacts], 
                                                  person.contact_ids] } }

  named_scope :period_events,
              lambda { |date_from, date_until| { :conditions => ['start_time >= ? and start_time <= ?',
                                                 date_from, date_until] } }

  after_create :log_activity
  
  def self.monthly_events(date)
    self.period_events(date.beginning_of_month, date.to_time.end_of_month)
  end
  
  def self.daily_events(date)
    self.period_events(date.beginning_of_day, date.to_time.end_of_day)
  end

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

  def only_contacts?
    self.privacy == PRIVACY[:contacts]
  end

  private

    def log_activity
      add_activities(:item => self, :person => self.person)
    end

end
