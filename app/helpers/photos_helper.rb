module PhotosHelper
  
  def photo_id(photo)
    photo.label_from_filename.gsub(/ /,'').gsub(/\./, "_")
  end
end
