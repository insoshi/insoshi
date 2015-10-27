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
      :available_count => 1,
      :group_id => 1,
      :person => p 
    }
  end
=begin
  XXX offer examples currently in group_spec

  it "should create a new instance given valid attributes" do
    Offer.create!(@valid_attributes)
  end
=end
end
