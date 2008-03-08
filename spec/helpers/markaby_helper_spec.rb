require File.dirname(__FILE__) + '/../spec_helper'

describe MarkabyHelper do
  
  # This is needed to get RSpec to understand link_to(..., person).
  def polymorphic_path(args)
    "http://a.fake.url"
  end

  it "should raster a list of people" do
    @image = mock_photo
    @people = [Person.new] * 10
    @people.each do |person|
      person.stub!(:icon).and_return("image.png")
    end
    list = @people.map { |person| link_to(image_tag(person.icon), person) }
    result = raster(list).to_s
    result.should have_tag("div")
    result.should have_tag("td") do
      with_tag("img[src=?]", "/images/image.png")
    end
  end
end
