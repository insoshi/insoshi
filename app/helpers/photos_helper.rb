module PhotosHelper
  def photo_title(filename)
    File.basename(filename, File.extname(filename)).titleize
  end
end
