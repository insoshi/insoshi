require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  it "should be valid" do
    Forum.new.should be_valid
  end
  
  it "should have topics" do
    forums(:one).topics.should be_an(Array)
  end
  
  it "should have posts" do
    forums(:one).posts.should be_an(Array)
  end
end
