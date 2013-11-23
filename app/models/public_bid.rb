class PublicBid

  def self.open?
    Preference.first.public_private_bid
  end

  def self.close?
    !self.open?
  end

end