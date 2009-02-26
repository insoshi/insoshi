# == Schema Information
# Schema version: 20090216032013
#
# Table name: bids
#
#  id              :integer(4)      not null, primary key
#  req_id          :integer(4)      
#  person_id       :integer(4)      
#  status_id       :integer(4)      
#  estimated_hours :decimal(8, 2)   default(0.0)
#  actual_hours    :decimal(8, 2)   default(0.0)
#  expiration_date :datetime        
#  created_at      :datetime        
#  updated_at      :datetime        
#  accepted_at     :datetime        
#  committed_at    :datetime        
#  completed_at    :datetime        
#  approved_at     :datetime        
#  rejected_at     :datetime        
#

class Bid < ActiveRecord::Base
  belongs_to :req
  belongs_to :person
  validates_presence_of :estimated_hours, :person_id
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
