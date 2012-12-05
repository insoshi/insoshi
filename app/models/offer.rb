require 'texticle/searchable'

class Offer < ActiveRecord::Base
  include ActivityLogger
  include AnnouncementBase

  extend Searchable(:name, :description)

  module Scopes
    def active
      where("available_count > ? AND expiration_date >= ?", 0, DateTime.now)
    end
  end

  extend Scopes

  before_create :set_available_count

  validates :expiration_date, :total_available, :presence => true

  def considered_active?
    available_count > 0 && expiration_date >= DateTime.now
  end

  private
    def set_available_count
      self.available_count = self.total_available
    end

end
