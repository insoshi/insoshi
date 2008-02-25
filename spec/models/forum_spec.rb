require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  before(:each) do
    @forum = Forum.new
  end

  it "should be valid" do
    @forum.should be_valid
  end
end
