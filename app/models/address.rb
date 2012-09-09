# == Schema Information
# Schema version: 20090216032013
#
# Table name: addresses
#
#  id             :integer(4)      not null, primary key
#  person_id      :integer(4)      
#  name           :string(50)      
#  address_line_1 :string(50)      
#  address_line_2 :string(50)      
#  address_line_3 :string(50)      
#  city           :string(50)      
#  county_id      :string(255)     
#  state_id       :integer(4)      
#  zipcode_plus_4 :string(10)      
#  latitude       :decimal(12, 8)  not null
#  longitude      :decimal(12, 8)  not null
#  created_at     :datetime        
#  updated_at     :datetime        
#

class Address < ActiveRecord::Base
  belongs_to :person
  belongs_to :state
  before_validation :geocode_address
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  def to_s
    Address.string_representation(address_line_1, address_line_2, address_line_3, city, state.try(:abbreviation), zipcode_plus_4)
  end


  def Address.string_representation(address_line_1, address_line_2, address_line_3, city,  state, zipcode_plus_4)
    [address_line_1, address_line_2, address_line_3, city, state, zipcode_plus_4].collect(&:presence).compact.join(", ")
  end
  
  
  private
  def geocode_address
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(self.to_s)
    if geo.success
      self.latitude, self.longitude = geo.lat, geo.lng
    else
      errors.add(:base, 'Could not geocode address.')
    end    
  end


end
