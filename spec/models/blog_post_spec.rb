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
      @post.comments.build(:body => "The body", :commenter => people(:aaron))
      @post.save!
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
    
    it "should log a blog post event" do
      Event.find_by_instance_id(@post).should_not be_nil
    end
    
    it "should have an event" do
      @post.event.should_not be_nil
    end
    
    it "should destroy associated events" do
      event = @post.event
      @post.destroy
      lambda do
        BlogPostEvent.find(event)
      end.should raise_error(ActiveRecord::RecordNotFound)
    end
    
    
    
  end
end
