require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before(:each) do
    @activity = Activity.new
  end

  it "should be valid" do
    @activity.should be_valid
  end
end
