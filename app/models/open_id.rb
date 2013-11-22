
class OpenId < ActiveRecord::Base

  def self.open?
    OpenId.first.open_id
  end

  def self.close?
    !self.open?
  end
end