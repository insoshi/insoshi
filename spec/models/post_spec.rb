require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  include CustomModelMatchers
  
  it "should be valid" do
    Post.new(:body => "Hey there").should be_valid
  end
  
  it "should require a body" do
    post = Post.new
    post.should_not be_valid
    post.errors.on(:body).should_not be_empty
  end
  
  it "should have a maximum body length" do
    Post.should have_maximum(:body, MAX_TEXT_LENGTH)
  end
end
