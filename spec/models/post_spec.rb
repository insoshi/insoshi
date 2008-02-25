require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  before(:each) do
    @post = Post.new
  end

  it "should be valid" do
    @post.should be_valid
  end
end
