# == Schema Information
# Schema version: 20090216032013
#
# Table name: reqs
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  description     :text
#  estimated_hours :decimal(8, 2)   default(0.0)
#  due_date        :datetime
#  person_id       :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  active          :boolean(1)      default(TRUE)
#  twitter         :boolean(1)
#

class Req < ActiveRecord::Base
  include ActivityLogger
  extend PreferencesHelper

  index do
    name
    description
  end

  scope :active, :conditions => ["active IS true AND due_date >= ?", DateTime.now]
  scope :with_group_id, lambda {|group_id| {:conditions => ['group_id = ?', group_id]}}
  scope :search_by, lambda { |text|
    where("lower(name) LIKE ? OR lower(description) LIKE ?","%#{text}%".downcase,"%#{text}%".downcase)
  }
  scope :biddable, where("biddable = ?", true)
  scope :current, lambda { where("due_date >= ?", DateTime.now) }
  scope :without_approved_bid,
    joins("LEFT JOIN bids AS approved_bids ON approved_bids.req_id = reqs.id AND approved_bids.state = 'approved'").
    where("approved_bids.id IS NULL")

  has_and_belongs_to_many :categories
  has_many :workers, :through => :categories, :source => :people
  has_and_belongs_to_many :neighborhoods
  belongs_to :person
  belongs_to :group
  has_many :bids, :order => 'created_at DESC', :dependent => :destroy
  has_many :accepted_bids, :class_name => "Bid", :conditions => "accepted_at IS NOT NULL"
  has_many :completed_bids, :class_name => "Bid", :conditions => "completed_at IS NOT NULL"
  has_many :committed_bids, :class_name => "Bid", :conditions => "committed_at IS NOT NULL"
  has_many :approved_bids, :class_name => "Bid", :conditions => "approved_at IS NOT NULL"
  has_many :exchanges, :as => :metadata

  attr_accessor :ability
  attr_protected :ability
  attr_protected :person_id, :created_at, :updated_at
  attr_readonly :estimated_hours
  attr_readonly :group_id
  validates_presence_of :name, :due_date
  validates_presence_of :group_id
  validate :group_has_a_currency_and_includes_requestor_as_a_member
  validate :maximum_categories

  before_create :make_active, :if => :biddable
  after_create :send_req_notifications, :if => :notifications
  after_create :log_activity

  class << self

    def current_and_active(page=1)
      self.biddable.current.without_approved_bid.page(page).order('created_at DESC')
    end

    def all_active(page=1)
      self.biddable.page(page).order('created_at DESC')
    end

    def search(category, group, active_only, page, posts_per_page, search=nil)
      if category
        chain = category.reqs.with_group_id(group.id)
      else
        chain = group.reqs
        chain = chain.search_by(search) if search
      end

      chain = chain.active if active_only
      chain.paginate(:page => page, :per_page => posts_per_page)
    end
  end

  def considered_active?
    active? && (due_date > DateTime.now)
  end

  def deactivate
    update_attributes(:active => false)
  end

  def unit
    group.unit
  end

  def long_categories
    categories.map {|cat| cat.long_name }
  end

  def has_accepted_bid?
    return bids.any? &:accepted_at if bids.loaded?
    !accepted_bids.empty?
  end

  def has_completed?
    return bids.any? &:completed_at if bids.loaded?
    !completed_bids.empty?
  end

  def has_commitment?
    return bids.any? &:committed_at if bids.loaded?
    !committed_bids.empty?
  end

  def has_approved?
    return bids.any? &:approved_at if bids.loaded?
    !approved_bids.empty?
  end

  def log_activity
    if active?
      add_activities(:item => self, :person => self.person, :group => self.group)
    end
  end

  def notifiable_workers
    workers.active.connection_notifications
  end

  def should_send_notifications?
    active and Req.global_prefs.can_send_email? and Req.global_prefs.email_notifications?
  end

  # private

  def maximum_categories
    if self.categories.length > 5
      errors.add_to_base('Only 5 categories are allowed per request')
    end
  end

  def group_has_a_currency_and_includes_requestor_as_a_member
    unless self.group.nil?
      unless self.group.adhoc_currency?
        errors.add(:group_id, "does not have its own currency")
      end
      unless person.groups.include?(self.group)
        errors.add(:group_id, "does not include you as a member")
      end
    end
  end

  def make_active
    self.active = true
  end

  def send_req_notifications
    notifiable_workers.each do |worker|
      after_transaction { PersonMailerQueue.req_notification(self, worker) }
    end if should_send_notifications?
  end

end
