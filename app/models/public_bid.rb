class PublicBid < ActiveRecord::Base

  def self.open?
    PublicBid.first.public_bid
  end

  def self.close?
    !self.open?
  end

end