require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
  before(:each) do
    @event = Event.new
  end

  it "should be valid" do
    @event.should be_valid
  end
end
