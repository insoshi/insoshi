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
  extend PreferencesHelper
  before_validation :setup, :on => :create
  after_create :trigger_offered

  include Rails.application.routes.url_helpers
  include AASM

  belongs_to :req
  belongs_to :person
  belongs_to :group
  attr_readonly :estimated_hours

  validates_presence_of :estimated_hours, :person_id
  validate :estimated_hours_is_positive
  validate :group_includes_bidder_as_a_member

  attr_protected :person_id, :created_at, :updated_at
  attr_protected :status_id, :state
  attr_protected :group_id

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

  def unit
    if group.nil?
      I18n.translate('currency_unit_plural')
    else
      group.unit
    end
  end

  private

  def server
    @server ||= Bid.global_prefs.server_name
  end

  def estimated_hours_is_positive
    unless estimated_hours > 0
      errors.add(:estimated_hours, "must be greater than zero")
    end
  end

  def group_includes_bidder_as_a_member
    unless self.group.nil?
      unless self.person.groups.include?(self.group)
        errors.add(:group_id, "does not include you as a member")
      end
    end
  end

  def setup
    self.group = self.req.group
    if self.expiration_date.blank?
      self.expiration_date = 7.days.from_now
    else
      self.expiration_date += 1.day - 1.second # make expiration date at end of day
    end
  end

  def trigger_offered
    bid_note = Message.new()
    subject = "BID: " + self.estimated_hours.to_s + " hours - " + self.req.name 
    bid_note.subject = subject.mb_chars.length > 75 ? subject.mb_chars.slice(0,75).concat("...") : subject
    bid_note.content = ""
    bid_note.content << self.private_message_to_requestor + "\n--\n\n" if self.private_message_to_requestor.length > 0
    bid_note.content << "See your <a href=\"" + "http://" + server + req_path(self.req) + "\">request</a> to consider bid"
    bid_note.sender = self.person
    bid_note.recipient = self.req.person
    bid_note.save!
  end

  def trigger_accepted
    self.accepted_at = Time.now
    save
    bid_note = Message.new()
    subject = "Bid accepted for " + self.req.name
    bid_note.subject = subject.mb_chars.length > 75 ? subject.mb_chars.slice(0,75).concat("...") : subject
    bid_note.content = "See the <a href=\"" + "http://" + server + req_path(self.req) + "\">request</a> to commit to bid"
    bid_note.sender = self.req.person
    bid_note.recipient = self.person
    bid_note.save!
  end

  def trigger_committed
    self.committed_at = Time.now
    save
    bid_note = Message.new()
    subject = "Bid committed for " + self.req.name
    bid_note.subject = subject.mb_chars.length > 75 ? subject.mb_chars.slice(0,75).concat("...") : subject
    bid_note.content = "Commitment made for your <a href=\"" + "http://" + server + req_path(self.req) + "\">request</a>. This is an automated message"
    bid_note.sender = self.person
    bid_note.recipient = self.req.person
    bid_note.save!
  end

  def trigger_completed
    self.completed_at = Time.now
    save
    bid_note = Message.new()
    subject = "Work completed for " + self.req.name
    bid_note.subject = subject.mb_chars.length > 75 ? subject.mb_chars.slice(0,75).concat("...") : subject
    bid_note.content = "Work completed for your <a href=\"" + "http://" + server + req_path(self.req) + "\">request</a>. Please approve transaction! This is an automated message"
    bid_note.sender = self.person
    bid_note.recipient = self.req.person
    bid_note.save!
  end

  def trigger_approved
    self.approved_at = Time.now
    save

    Account.transfer(self.req.person, self.person, self.estimated_hours, self.req)
  end
end
