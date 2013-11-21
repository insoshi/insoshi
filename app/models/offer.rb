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

  has_many :photos, :as => :photoable, dependent: :destroy

  before_create :set_available_count

  validates :expiration_date, :total_available, :presence => true

  accepts_nested_attributes_for :photos, :allow_destroy => true
  
  def considered_active?
    available_count > 0 && expiration_date >= DateTime.now
  end

  def calculate_amount(count)
    return nil unless (count.blank? or count.is_a?(Fixnum))
    if count.blank?
      price
    else
      price * count if (count > 0 && count <= available_count)
    end
  end

  ## Photo helpers
  def photo
    # This should only have one entry, but be paranoid.
    # assuming an offer only has at most one photo even though it is a has_many relationship
    photos.first
  end

  # Return all the photos other than the primary one
  def other_photos
    photos.length > 1 ? photos - [photo] : []
  end

  def main_photo
    photo.nil? ? (person.photo.nil? ? "g_default.png" : person.photo.picture_url) : photo.picture_url
  end

  def thumbnail
    photo.nil? ? (person.photo.nil? ? "g_default_thumbnail.png" : person.photo.picture_url(:thumbnail)) : photo.picture_url(:thumbnail)
  end

  def icon
    photo.nil? ? (person.photo.nil? ? "g_default_icon.png" : person.photo.picture_url(:icon)) : photo.picture_url(:icon)
  end

  private
    def set_available_count
      self.available_count = self.total_available
    end

end
