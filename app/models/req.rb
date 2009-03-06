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
    if !twitter?
      logger.info "No twitter requested for [#{id}:#{name}]"
      return
    end

    twitter_name = Req.global_prefs.twitter_name
    twitter_password = Req.global_prefs.plaintext_twitter_password
    twitter_api = Req.global_prefs.twitter_api

    twit = Twitter::Base.new(twitter_name,twitter_password, :api_host => twitter_api )
    begin
      twit.update("#{name}: #{url}")
    rescue Twitter::CantConnect => e
      logger.info "ERROR Twitter::CantConnect for [#{id}:#{name}] (" + e.to_s + ")"
    end
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
      add_activities(:item => self, :person => self.person)
    end
  end
end
