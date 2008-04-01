require File.dirname(__FILE__) + '/../spec_helper'

describe BlogPostComment do
    
  before(:each) do
    @comment = BlogPostComment.new(:body => "Hey there", :post => posts(:blog),
                                   :commenter => people(:aaron))
    
  end
  
  it "should be valid" do
    @comment.should be_valid
  end
  
  it "should require a body" do
    comment = BlogPostComment.new
    comment.should_not be_valid
    comment.errors.on(:body).should_not be_empty
  end
  
  it "should have a maximum body length" do
    @comment.should have_maximum(:body, MAX_TEXT_LENGTH)
  end
  
  describe "associations" do
    
    before(:each) do
      @comment.save!
      @activity = Activity.find_by_item_id(@comment)      
    end

    it "should have an activity" do
      @activity.should_not be_nil
    end
    
    it "should add an activity to the poster" do
      @comment.post.blog.person.activities.include?(@activity).should == true
    end

    it "should add an activity to the commenter" do
      @comment.commenter.activities.include?(@activity).should == true      
    end
  end
end
