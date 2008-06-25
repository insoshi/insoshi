require File.dirname(__FILE__) + '/../spec_helper'

describe Thumbnail do
  it "should be valid" do
    @thumbnail = Thumbnail.new({:parent_id => 1})
    @thumbnail.should be_valid
  end
  
  it "should be invalid without parent_id" do
    @thumbnail = Thumbnail.new
    @thumbnail.should_not be_valid
  end
end
