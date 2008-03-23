require File.dirname(__FILE__) + '/../spec_helper'

describe BlogPostComment do
  include CustomModelMatchers
  
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
      @event = Event.find_by_item_id(@comment)      
    end

    it "should have an event" do
      @event.should_not be_nil
    end
    
    it "should add an event to the poster" do
      @comment.post.blog.person.events.include?(@event).should == true
    end

    it "should add an event to the commenter" do
      @comment.commenter.events.include?(@event).should == true      
    end
  end
end
