# == Schema Information
# Schema version: 34
#
# Table name: feeds
#
#  id          :integer         not null, primary key
#  person_id   :integer         
#  activity_id :integer         
#

class Feed < ActiveRecord::Base
  belongs_to :activity
  belongs_to :person
end
