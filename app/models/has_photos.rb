module HasPhotos
  extend ActiveSupport::Concern

  included do
    has_many :photos, :as => :photoable, dependent: :destroy
    accepts_nested_attributes_for :photos, :allow_destroy => true
  end

  ## Photo helpers
  def photo
    # This should only have one entry, but be paranoid.
    # assuming an offer/req only has at most one photo even though it is a has_many relationship
    photos.first
  end

  # Return all the photos other than the primary one
  def other_photos
    photos.length > 1 ? photos - [photo] : []
  end

  def main_photo
    photo.nil? ? (person.photo.nil? ? Preference.group_image : person.photo.picture_url) : photo.picture_url
  end

  def polaroid
    photo.nil? ? (person.photo.nil? ? Preference.group_image(:polaroid) : person.photo.picture_url(:polaroid)) : photo.picture_url(:polaroid)
  end

  def thumbnail
    photo.nil? ? (person.photo.nil? ? Preference.group_image(:thumbnail) : person.photo.picture_url(:thumbnail)) : photo.picture_url(:thumbnail)
  end

  def icon
    photo.nil? ? (person.photo.nil? ? Preference.group_image(:icon) : person.photo.picture_url(:icon)) : photo.picture_url(:icon)
  end

end
