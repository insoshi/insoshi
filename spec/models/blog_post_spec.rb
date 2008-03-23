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
    @post.should have_maximum(:body, BlogPost::MAX_BODY)
  end
    
  describe "post event associations" do
    
    before(:each) do
      @post.save!
      @event = Event.find_by_item_id(@post)
    end
    
    it "should have an event" do
      @event.should_not be_nil
    end
    
    it "should add an event to the poster" do
      @post.blog.person.events.include?(@event).should == true
    end
    
    it "should destroy the associated event" do
      @post.should destroy_associated(:event)
    end
  end
  
  describe "comment associations" do
    
    before(:each) do
      @post.comments.build(:body => "The body", :commenter => people(:aaron))      
      @post.save!
    end
    
    it "should have associated comments" do
      @post.comments.should_not be_empty
    end
    
    it "should add events to the poster" do
      @post.comments.each do |comment|
        event = Event.find_by_item_id(comment)
        @post.blog.person.events.include?(event).should == true
      end
    end
    
    it "should destroy associated comments" do
      @post.should destroy_associated(:comments)
    end
  end
end
