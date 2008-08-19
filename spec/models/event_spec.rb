require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :description => "value for description",
      :person => people(:aaron),
      :start_time => Time.now,
      :end_time => Time.now,
      :reminder => false
    }
  end

  it "should create a new instance given valid attributes" do
    Event.create!(@valid_attributes)
  end
end
