class Bid < ActiveRecord::Base
  belongs_to :req
  belongs_to :person
  validates_presence_of :estimated_hours
  attr_readonly :estimated_hours

  attr_protected :person_id, :status_id, :created_at, :updated_at

  INACTIVE = 1
  OFFERED = 2
  ACCEPTED = 3
  COMMITTED = 4
  COMPLETED = 5
  SATISFIED = 6
  NOT_SATISFIED = 7

end
