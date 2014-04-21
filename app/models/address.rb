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
  belongs_to :person, :inverse_of => :addresses
  belongs_to :state

  attr_accessible :address_line_1, :address_line_2, :address_line_3, :city, :state_id, :zipcode_plus_4, :address_privacy
  attr_accessible :primary
  attr_accessible *attribute_names, :as => :admin

  attr_accessible :person_attributes, :allow_destroy => true
  accepts_nested_attributes_for :person, :allow_destroy => true

  after_commit :geocode_address, :if => :persisted?
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  def to_s
    Address.string_representation(address_line_1, address_line_2, address_line_3, city, state.try(:abbreviation), zipcode_plus_4)
  end


  def Address.string_representation(address_line_1, address_line_2, address_line_3, city,  state, zipcode_plus_4)
    # Don't include City and State unless address_line_1 is present
    if address_line_1.blank?
      zipcode_plus_4
    else
      [address_line_1, address_line_2, address_line_3, city, state, zipcode_plus_4].collect(&:presence).compact.join(", ")
    end
  end
 
  def perform
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(self.to_s)
    if geo.success
      update_column(:latitude, geo.lat)
      update_column(:longitude, geo.lng)
    else
      Rails.logger.info "Address#perform fail"
    end    
  end
  
  private
  def geocode_address
    AddressQueue.push(:id => self.id)
  end
end
