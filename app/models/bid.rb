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
  include ActionController::UrlWriter
  include AASM

  belongs_to :req
  belongs_to :person
  validates_presence_of :estimated_hours, :person_id
  attr_readonly :estimated_hours

  attr_protected :person_id, :created_at, :updated_at
  attr_protected :status_id, :state

  aasm_column :state

  aasm_initial_state :offered

  aasm_state :offered
  aasm_state :accepted, :enter => :trigger_accepted
  aasm_state :committed, :enter => :trigger_committed
  aasm_state :completed, :enter => :trigger_completed
  aasm_state :approved, :enter => :trigger_approved

  aasm_event :accept do
    transitions :to => :accepted, :from => :offered
  end

  aasm_event :commit do
    transitions :to => :committed, :from => :accepted
  end

  aasm_event :complete do
    transitions :to => :completed, :from => :committed
  end

  aasm_event :pay do
    transitions :to => :approved, :from => [:accepted,:committed,:completed]
  end

  def requestor_event_for_current_state
    requestor_events = requestor_events_for_current_state
    requestor_events[0]
  end

  def bidder_event_for_current_state
    bidder_events = bidder_events_for_current_state
    bidder_events[0]
  end

  def requestor_events_for_current_state
    r_events = aasm_events_for_current_state.map {|event| event.to_s}
    r_events.find_all {|event| ['accept','pay'].include? event}
  end

  def bidder_events_for_current_state
    b_events = aasm_events_for_current_state.map {|event| event.to_s}
    b_events.find_all {|event| ['commit','complete'].include? event}
  end

  private

  def trigger_accepted
    self.accepted_at = Time.now
    save
    bid_note = Message.new()
    subject = "Bid accepted for " + self.req.name
    bid_note.subject = subject.length > 75 ? subject.slice(0,75).concat("...") : subject
    bid_note.content = "See the <a href=\"" + req_path(self.req) + "\">request</a> to commit to bid"
    bid_note.sender = self.req.person
    bid_note.recipient = self.person
    bid_note.save!
  end

  def trigger_committed
    self.committed_at = Time.now
    save
    bid_note = Message.new()
    subject = "Bid committed for " + self.req.name
    bid_note.subject = subject.length > 75 ? subject.slice(0,75).concat("...") : subject
    bid_note.content = "Commitment made for your <a href=\"" + req_path(self.req) + "\">request</a>. This is an automated message"
    bid_note.sender = self.person
    bid_note.recipient = self.req.person
    bid_note.save!
  end

  def trigger_completed
    self.completed_at = Time.now
    save
    bid_note = Message.new()
    subject = "Work completed for " + self.req.name
    bid_note.subject = subject.length > 75 ? subject.slice(0,75).concat("...") : subject
    bid_note.content = "Work completed for your <a href=\"" + req_path(self.req) + "\">request</a>. Please approve transaction! This is an automated message"
    bid_note.sender = self.person
    bid_note.recipient = self.req.person
    bid_note.save!
  end

  def trigger_approved
    self.approved_at = Time.now
    save
    Account.transfer(self.req.person.account,self.person.account,self.estimated_hours,self.req)
    bid_note = Message.new()
    subject = "Verified work for " + self.req.name + " (#{self.estimated_hours} hours earned)"
    bid_note.subject = subject.length > 75 ? subject.slice(0,75).concat("...") : subject
    bid_note.content = "#{self.req.person.name} has verified your work for <a href=\"" + req_path(self.req) + "\">#{self.req.name}</a>. This is an automated message"
    bid_note.sender = self.req.person
    bid_note.recipient = self.person
    bid_note.save!
  end
end
