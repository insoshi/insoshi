require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "blog post comments" do
    
    before(:each) do
      @post = posts(:blog_post)
      @comment = @post.comments.unsafe_build(:body => "Hey there",
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
        @comment.commentable.blog.person.activities.
          should contain(@activity)
      end

      it "should add an activity to the commenter" do
        @comment.commenter.recent_activity.should contain(@activity)
      end
    end
    
    describe "feed items for contacts" do
      it %(should not have duplicate items when a contact comments
           on a blog) do
        @person = @post.blog.person
        @commenter = @comment.commenter
        Connection.connect(@person, @commenter)
        @comment.save!
        @person.activities.should have_distinct_elements
      end
    end
    
    describe "email notifications" do
      
      before(:each) do
        @emails = ActionMailer::Base.deliveries
        @emails.clear
        @global_prefs = Preference.find(:first)
        @recipient = @comment.commented_person
      end
      
      it "should send an email when global/recipient notifications are on" do
        # Both notifications are on by default.
        lambda do
          @comment.save
        end.should change(@emails, :length).by(1)
      end
      
      it "should not send an email when recipient's notifications are off" do
        @recipient.toggle!(:blog_comment_notifications)
        @recipient.blog_comment_notifications.should == false
        lambda do
          @comment.save
        end.should_not change(@emails, :length)
      end
      
      it "should not send an email when global notifications are off" do
        @global_prefs.update_attributes(:email_notifications => false)
        lambda do
          @comment.save
        end.should_not change(@emails, :length)
      end
      
      it "should not send an email for an own-comment" do
        lambda do
          commenter = @post.blog.person
          comment = @post.comments.unsafe_create(:body => "Hey there",
                                                 :commenter => commenter)
        end.should_not change(@emails, :length)
      end
    end
  end

  describe "wall comments" do
  
    before(:each) do
      @person = people(:quentin)
      @comment = @person.comments.unsafe_build(:body => "Hey there",
                                               :commenter => people(:aaron))
    end
  
    it "should be valid" do
      @comment.should be_valid
    end
  
    it "should require a body" do
      comment = @person.comments.new
      comment.should_not be_valid
      comment.errors.on(:body).should_not be_empty
    end
  
    it "should have a maximum body length" do
      @comment.should have_maximum(:body, MEDIUM_TEXT_LENGTH)
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
    
    describe "email notifications" do
    
      before(:each) do
        @emails = ActionMailer::Base.deliveries
        @emails.clear
        @global_prefs = Preference.find(:first)
        @recipient = @comment.commented_person
      end
    
      it "should send an email when global/recipient notifications are on" do
        # Both notifications are on by default.
        lambda do
          @comment.save
        end.should change(@emails, :length).by(1)
      end
    
      it "should not send an email when recipient's notifications are off" do
        @recipient.toggle!(:wall_comment_notifications)
        @recipient.wall_comment_notifications.should == false
        lambda do
          @comment.save
        end.should_not change(@emails, :length)
      end
    
      it "should not send an email when global notifications are off" do
        @global_prefs.update_attributes(:email_notifications => false)
        lambda do
          @comment.save
        end.should_not change(@emails, :length)
      end
      
      it "should not send an email for an own-comment" do
        lambda do
          @person.comments.create(:body => "Hey there",
                                  :commenter => @person)
        end.should_not change(@emails, :length)
      end
    end
  end
  
  describe "feed items for contacts" do

    before(:each) do
      @person = people(:quentin)
      @contact = people(:aaron)
      @second_contact = people(:kelly)
      Connection.connect(@person, @contact)
      Connection.connect(@person, @second_contact)
    end
    
    # When one of your contacts comments on his own wall,
    # an activity might get created for both the commenter and the commented.
    # Here they are the same person, so only one item should be craeted.
    it "should not have duplicate feed items when commenting on own wall" do
      Connection.connected?(@person, @contact).should be_true
      @contact.comments.create(:body => "Hey there", :commenter => @contact)
      @person.activities.should have_distinct_elements
    end
    
    it %(should not have duplicate feed items for Quentin
         when Kelly comments on Aaron's wall) do
      @contact.comments.create(:body => "bar", :commenter => @second_contact)
      @person.activities.should have_distinct_elements
    end
  end
end
