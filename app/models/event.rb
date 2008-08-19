class Event < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :title, :start_time, :person
end
