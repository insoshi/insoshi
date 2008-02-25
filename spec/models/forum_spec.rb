require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  it "should be valid" do
    Forum.new.should be_valid
  end
end
