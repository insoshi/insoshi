class Offer < ActiveRecord::Base
  include ActivityLogger
  include AnnouncementBase

  index do
    name
    description
  end

  module Scopes
    def active
      where("available_count > ? AND expiration_date >= ?", 0, DateTime.now)
    end
  end

  extend Scopes

  validates :expiration_date, :total_available, :presence => true

end
