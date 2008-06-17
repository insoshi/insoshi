module PhotosHelper
  def photo_title(filename)
    File.basename(filename, File.extname(filename)).titleize
  end
  
  def photo_id(photo)
    photo_title(photo.filename).gsub(/ /,'')
  end
end
