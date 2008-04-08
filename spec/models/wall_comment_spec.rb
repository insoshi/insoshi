require File.dirname(__FILE__) + '/../spec_helper'

describe WallComment do
  
  before(:each) do
    @comment = WallComment.new(:body => "Hey there",
                               :commentable => people(:quentin),
                               :commenter => people(:aaron))
  end
  
  it "should be valid" do
    @comment.should be_valid
  end
  
  it "should require a body" do
    comment = WallComment.new
    comment.should_not be_valid
    comment.errors.on(:body).should_not be_empty
  end
  
  it "should have a maximum body length" do
    @comment.should have_maximum(:body, SMALL_TEXT_LENGTH)
  end
  
  it "should increase the comment count" do
    lambda do
      @comment.save!
    end.should change(WallComment, :count).by(1)
  end
  
  describe "associations" do
    
    before(:each) do
      @comment.save!
    end

    it "should have an activity" do
      Activity.find_by_item_id(@comment).should_not be_nil
    end
  end
end

