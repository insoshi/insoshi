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

  # The polaroid version was introduced recently (2017 Feb). Thus it may not exist in older photos.
  # The method will check to make sure that it is the case or return an equivalent `thumbnail`
  # version of the image.
  def polaroid
    if photo
      photo.picture_url (photo.highres ? :polaroid : :thumbnail)
    else
      # TODO The preference provides group picture image, if this is insufficient, that might need
      #   be patched to handle new highres photos.
      fallback_photo = person.photo || Preference.first.default_group_picture
      version = fallback_photo.highres ? :polaroid : :thumbnail rescue nil
      version ? fallback_photo.picture_url(version) : '#'
    end
  end

  def thumbnail
    photo.nil? ? (person.photo.nil? ? Preference.group_image(:thumbnail) : person.photo.picture_url(:thumbnail)) : photo.picture_url(:thumbnail)
  end

  def icon
    photo.nil? ? (person.photo.nil? ? Preference.group_image(:icon) : person.photo.picture_url(:icon)) : photo.picture_url(:icon)
  end

end
