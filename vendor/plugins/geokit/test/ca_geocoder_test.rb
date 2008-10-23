require File.join(File.dirname(__FILE__), 'base_geocoder_test')

GeoKit::Geocoders::geocoder_ca = "SOMEKEYVALUE"

class CaGeocoderTest < BaseGeocoderTest #:nodoc: all
  
  CA_SUCCESS=<<-EOF
  <?xml version="1.0" encoding="UTF-8" ?>
  <geodata><latt>49.243086</latt><longt>-123.153684</longt></geodata>  
  EOF
  
  def setup
    @ca_full_hash = {:street_address=>"2105 West 32nd Avenue",:city=>"Vancouver", :state=>"BC"}
    @ca_full_loc = GeoKit::GeoLoc.new(@ca_full_hash)
  end  
  
  def test_geocoder_with_geo_loc_with_account
    response = MockSuccess.new
    response.expects(:body).returns(CA_SUCCESS)
    url = "http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&geoit=xml"
    GeoKit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    verify(GeoKit::Geocoders::CaGeocoder.geocode(@ca_full_loc))    
  end
  
  def test_service_unavailable
    response = MockFailure.new
    #Net::HTTP.expects(:get_response).with(URI.parse("http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&geoit=xml")).returns(response)  
    url = "http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&geoit=xml" 
    GeoKit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !GeoKit::Geocoders::CaGeocoder.geocode(@ca_full_loc).success   
  end  
  
  private
  
  def verify(location)
    assert_equal "BC", location.state
    assert_equal "Vancouver", location.city 
    assert_equal "49.243086,-123.153684", location.ll 
    assert !location.is_us? 
  end
end