class Req < ActiveRecord::Base
  include ActivityLogger

  has_and_belongs_to_many :categories
  belongs_to :person
  has_many :bids

  attr_protected :person_id, :created_at, :updated_at

  after_create :log_activity

  def has_commitment?
    a = false
    bids.each {|bid| a = true if bid.status_id > Bid::ACCEPTED }
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
    add_activities(:item => self, :person => self.person)
  end
end
