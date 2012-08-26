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
  include Rails.application.routes.url_helpers
  include AASM

  extend PreferencesHelper
  before_validation :setup, :on => :create
  after_create :trigger_offered

  belongs_to :req
  belongs_to :person
  belongs_to :group
  attr_readonly :estimated_hours

  validates :person_id, :presence => true
  validates :estimated_hours, :presence => true, :numericality => { :greater_than => 0 }
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
    transitions :to => :approved, :from => [:accepted, :committed, :completed]
  end

  def requestor_event_for_current_state
    ([:accept, :pay] & aasm_events_for_current_state).first.to_s.presence
  end

  def bidder_event_for_current_state
    ([:commit, :complete] & aasm_events_for_current_state).first.to_s.presence
  end

  def unit
    group.try(:unit) || I18n.translate('currency_unit_plural')
  end

  # private

  def server
    @server ||= Bid.global_prefs.server_name
  end

  def group_includes_bidder_as_a_member
    unless self.group.nil? or self.person.groups.include?(self.group)
      errors.add(:group_id, "does not include you as a member")
    end
  end

  def setup
    self.group = self.req.group
    self.expiration_date = 7.days.from_now if self.expiration_date.blank?
    self.expiration_date = self.expiration_date.end_of_day
  end

  def trigger_offered
    Message.create! do |bid_note|
      bid_note.subject = "BID: #{estimated_hours} hours - #{req.name}"
      bid_note.content = ""
      bid_note.content << "#{private_message_to_requestor}\n--\n\n" if private_message_to_requestor.present?
      bid_note.content << "See your <a href=\"#{req_url(self.req)}\">request</a> to consider bid"
      bid_note.sender = self.person
      bid_note.recipient = self.req.person
    end
  end

  def trigger_accepted
    touch :accepted_at
    Message.create! do |bid_note|
      bid_note.subject = "Bid accepted for #{req.name}"
      bid_note.content = "See the <a href=\"#{req_url(self.req)}\">request</a> to commit to bid"
      bid_note.sender = self.req.person
      bid_note.recipient = self.person
    end
  end

  def trigger_committed
    touch :committed_at
    Message.create! do |bid_note|
      bid_note.subject = "Bid committed for #{req.name}"
      bid_note.content = "Commitment made for your <a href=\"#{req_url(self.req)}\">request</a>. This is an automated message"
      bid_note.sender = self.person
      bid_note.recipient = self.req.person
    end
  end

  def trigger_completed
    touch :completed_at
    Message.create! do |bid_note|
      bid_note.subject = "Work completed for #{req.name}"
      bid_note.content = "Work completed for your <a href=\"#{req_url(self.req)}\">request</a>. Please approve transaction! This is an automated message"
      bid_note.sender = self.person
      bid_note.recipient = self.req.person
    end
  end

  def trigger_approved
    touch :approved_at
    Account.transfer(self.req.person, self.person, self.estimated_hours, self.req)
  end
end
