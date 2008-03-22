# == Schema Information
# Schema version: 12
#
# Table name: feeds
#
#  id        :integer(11)     not null, primary key
#  person_id :integer(11)     
#  event_id  :integer(11)     
#

class Feed < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
end
