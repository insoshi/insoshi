require File.dirname(__FILE__) + '/../spec_helper'

describe WallComment do
  include CustomModelMatchers
  
  it "should be valid" do
    WallComment.new(:body => "Hey there",
                    :commenter => people(:aaron)).should be_valid
  end
  
  it "should require a body" do
    comment = WallComment.new
    comment.should_not be_valid
    comment.errors.on(:body).should_not be_empty
  end
  
  it "should have a maximum body length" do
    WallComment.should have_maximum(:body, MAX_TEXT_LENGTH)
  end
end

