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

  named_scope :active, :conditions => ["active IS true AND due_date >= ?", DateTime.now]
  named_scope :with_group_id, lambda {|group_id| {:conditions => ['group_id = ?', group_id]}}
  named_scope :search, lambda { |text| {:conditions => ["lower(name) LIKE ? OR lower(description) LIKE ?","%#{text}%".downcase,"%#{text}%".downcase]} }

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :neighborhoods
  belongs_to :person
  belongs_to :group
  has_many :bids, :order => 'created_at DESC', :dependent => :destroy
  has_many :exchanges, :as => :metadata

  attr_accessor :ability
  attr_protected :ability
  attr_protected :person_id, :created_at, :updated_at
  attr_readonly :estimated_hours
  attr_readonly :group_id
  validates_presence_of :name, :due_date
  validates_presence_of :group_id

  before_create :make_active, :if => :biddable
  after_create :send_req_notifications, :if => :notifications
  after_create :log_activity

  class << self

    def current_and_active(page=1)
      today = DateTime.now
      @reqs = Req.paginate(:all, :page => page, :conditions => ["biddable = ? AND due_date >= ?", true, today], :order => 'created_at DESC')
      @reqs.delete_if { |req| req.has_approved? }
    end

    def all_active(page=1)
      @reqs = Req.paginate(:all, :page => page, :conditions => ["biddable = ?", true], :order => 'created_at DESC')
    end

    def search(category,group,active_only,page,posts_per_page,search=nil)
      unless category
        chain = group.reqs
        chain = chain.search(search) if search
      else
        chain = category.reqs.with_group_id(group.id)
      end

      chain = chain.active if active_only
      chain.paginate(:page => page, :per_page => posts_per_page)
    end
  end

  def considered_active?
    active? && (due_date > DateTime.now)
  end

  def deactivate
    update_attribute(:active,false)
  end

  def unit
    group.unit
  end

  def formatted_categories
    categories.collect {|cat| cat.long_name + "<br>"}.to_s.chop.chop.chop.chop
  end

  def has_accepted_bid?
    a = false
    bids.each {|bid| a = true if bid.accepted_at != nil }
    return a
  end

  def has_completed?
    a = false
    bids.each {|bid| a = true if bid.completed_at != nil }
    return a
  end

  def has_commitment?
    a = false
    bids.each {|bid| a = true if bid.committed_at != nil }
    return a
  end

  def has_approved?
    a = false
    bids.each {|bid| a = true if bid.approved_at != nil }
    return a
  end

  def log_activity
    if active?
      add_activities(:item => self, :person => self.person, :group => self.group)
    end
  end

  def perform
    workers = []
    # even though pseudo-reqs created by direct payments do not have associated categories, let's
    # be extra cautious and check for the active property as well
    #
    if self.active? && Req.global_prefs.can_send_email? && Req.global_prefs.email_notifications?
      self.categories.each do |category|
        workers << category.people
      end

      workers.flatten!
      workers.uniq!
      workers.each do |worker|
        if worker.active?
          PersonMailer.deliver_req_notification(self, worker) if worker.connection_notifications?
        end
      end
    end
  end

  private

  def validate
    if self.categories.length > 5
      errors.add_to_base('Only 5 categories are allowed per request')
    end

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
    Cheepnis.enqueue(self)
  end
end
