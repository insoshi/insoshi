require File.dirname(__FILE__) + '/../spec_helper'

describe BlogPost do
  include CustomModelMatchers
  
  before(:each) do
    @post = BlogPost.new(:title => "First post!",
                         :body => "Hey there",
                         :blog => blogs(:one))
  end
  
  it "should be valid" do
    @post.should be_valid
  end
  
  it "should require a title" do
    post = BlogPost.new
    post.should_not be_valid
    post.errors.on(:title).should_not be_empty
  end
  
  it "should require a body" do
    post = BlogPost.new
    post.should_not be_valid
    post.errors.on(:body).should_not be_empty
  end
  
  it "should have a maximum body length" do
    @post.should have_maximum(:body, MAX_TEXT_LENGTH)
  end
  
  describe "associations" do
    
    before(:each) do
      @post = posts(:blog)
    end
    
    it "should have associated comments" do
      @post.comments.should_not be_empty
    end
    
    it "should destroy associated comments" do
      comments = @post.comments
      @post.destroy
      comments.each do |comment|
        lambda do
          BlogPostComment.find(comment)
        end.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
end
