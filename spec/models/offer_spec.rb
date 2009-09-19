require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Offer do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :price => 9.99,
      :expiration_date => Date.today,
      :person_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Offer.create!(@valid_attributes)
  end
end
