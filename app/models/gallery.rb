class Gallery < ActiveRecord::Base
  belongs_to :person
  has_many :photos, :dependent => :destroy
  
  @@per_page = 3
  
  # def primary_photo
  #   self.photos.find_all_by_primary(true).first
  # end
  

  def primary_photo
    if !self.primary_photo_id.nil?
      Photo.find(self.primary_photo_id)
    else
      nil
    end
  end
  
  def primary_photo= (photo)
    self.primary_photo_id = photo.id
  end
  
  def primary_photo_url
    primary_photo.nil? ? "default.png" : primary_photo.public_filename
  end

  def thumbnail_url
    primary_photo.nil? ? "default_thumbnail.png" : primary_photo.public_filename(:thumbnail)
  end

  def icon_url
    primary_photo.nil? ? "default_icon.png" : primary_photo.public_filename(:icon)
  end

  def bounded_icon_url
    primary_photo.nil? ? "default_icon.png" : primary_photo.public_filename(:bounded_icon)
  end
  
end
