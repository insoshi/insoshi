class Address < ActiveRecord::Base
  belongs_to :person
  belongs_to :state
  before_validation :geocode_address
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  def to_s
    Address.string_representation(self.address_line_1, self.address_line_2, self.address_line_3, self.city,  self.state.nil? ? nil : self.state.abbreviation, self.zipcode_plus_4)
  end


  def Address.string_representation(address_line_1, address_line_2, address_line_3, city,  state, zipcode_plus_4)
    output = ''
    output += address_line_1 + ', ' unless address_line_1.blank?
    output += address_line_2 + ', ' unless address_line_2.blank?
    output += address_line_3 + ', ' unless address_line_3.blank?
    output += city + ', ' unless city.blank?
    output += state + ', ' unless state.nil?
    output += zipcode_plus_4 unless zipcode_plus_4.nil?
    return output
  end
  
  
  private
  def geocode_address
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(self.to_s)
    if geo.success
      self.latitude, self.longitude = geo.lat, geo.lng
    else
      errors.add(:name, 'Could not geocode address.')
    end    
  end


end
