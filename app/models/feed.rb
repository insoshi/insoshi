# == Schema Information
# Schema version: 20090216032013
#
# Table name: feeds
#
#  id          :integer(4)      not null, primary key
#  person_id   :integer(4)      
#  activity_id :integer(4)      
#

class Feed < ActiveRecord::Base
  belongs_to :activity
  belongs_to :person
end
