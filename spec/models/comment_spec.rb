require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "blog post comments" do
    
    before(:each) do
      @post = posts(:blog_post)
      @comment = @post.comments.new(:body => "Hey there",
                                    :commenter => people(:aaron))
    end
  
    it "should be valid" do
      @comment.should be_valid
    end
  
    it "should require a body" do
      comment = @post.comments.new
      comment.should_not be_valid
      comment.errors.on(:body).should_not be_empty
    end
  
    it "should have a maximum body length" do
      @comment.should have_maximum(:body, MAX_TEXT_LENGTH)
    end
  
    it "should increase the comment count" do
      old_count = @post.comments.count
      @comment.save!
      @post.comments.count.should == old_count + 1
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
        @comment.commentable.blog.person.activities.include?(@activity).
          should == true
      end

      it "should add an activity to the commenter" do
        @comment.commenter.activities.include?(@activity).should == true      
      end
    end
  end

  describe "wall comments" do
  
    before(:each) do
      @person = people(:quentin)
      @comment = @person.comments.new(:body => "Hey there",
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
      old_count = @person.comments.count
      @comment.save!
      @person.comments.count.should == old_count + 1
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
end
