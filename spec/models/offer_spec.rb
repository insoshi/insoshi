require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Offer do
  before(:each) do
    Preference.create
    p = people(:quentin)
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :price => 9.99,
      :expiration_date => Date.today,
      :total_available => 1,
      :person => p 
    }
  end

  it "should create a new instance given valid attributes" do
    Offer.create!(@valid_attributes)
  end
end
