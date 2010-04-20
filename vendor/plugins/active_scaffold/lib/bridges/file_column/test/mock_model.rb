class MockModel
  attr_accessor :name
  attr_accessor :bio
  
  attr_accessor :band_image
  attr_accessor :band_image_just_uploaded
  def band_image_just_uploaded?; self.band_image_just_uploaded ? true : false; end
  
end