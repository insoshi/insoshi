require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do
  
  before(:each) do
    @filename = "rails.png"
    @person = people(:quentin)
    @image = uploaded_file(@filename, "image/png")
  end
  
  it "should upload successfully" do
    new_photo.should be_valid
  end
  
  it "should be able to make a primary photo" do
    new_photo(:primary => true).should be_primary
  end
  
  it "should be able to make a non-primary photo" do
    new_photo(:primary => false).should_not be_primary    
  end
  
  
  it "should have an associated person" do
    new_photo.person.should == @person
  end
  
  it "should not have default AttachmentFu errors for an empty image" do
    photo = new_photo(:uploaded_data => nil)
    photo.should_not be_valid
    photo.errors[:size].should be_empty
    photo.errors[:base].should_not be_empty
  end
  
  private
  
    def new_photo(options = {})
      Photo.new({ :uploaded_data => @image,
                  :person        => @person }.merge(options))
    end
end
