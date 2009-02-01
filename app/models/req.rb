class Req < ActiveRecord::Base
  include ActivityLogger
  extend PreferencesHelper 

  is_indexed :fields => ['name', 'description']

  has_and_belongs_to_many :categories
  belongs_to :person
  has_many :bids, :order => 'created_at DESC'

  attr_protected :person_id, :created_at, :updated_at
  validates_presence_of :name, :due_date
  after_create :log_activity

  class << self

    def current_and_active
      today = DateTime.now
      @reqs = Req.find(:all, :conditions => ["active = ? AND due_date >= ?", 1, today], :order => 'created_at DESC')
      @reqs.delete_if { |req| req.has_approved? }
    end
  end

  def tweet(url)
    twitter_name = Req.global_prefs.twitter_name
    twitter_password = Req.global_prefs.plaintext_twitter_password

    twit = Twitter::Base.new(twitter_name,twitter_password)
    twit.update("#{name}: #{url}")
  end

  def has_approved?
    a = false
    bids.each {|bid| a = true if bid.status_id == Bid::SATISFIED }
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

  def committed_bid
    cbid = nil
    bids.each {|bid| cbid = bid if bid.status_id > Bid::ACCEPTED }
    return cbid
  end

  def has_accepted_bid?
    a = false
    bids.each {|bid| a = true if bid.status_id > Bid::OFFERED }
    return a
  end

  def accepted_bid
    abid = nil
    bids.each {|bid| abid = bid if bid.status_id > Bid::OFFERED }
    return abid
  end

  def log_activity
    if active?
      add_activities(:item => self, :person => self.person)
    end
  end
end
