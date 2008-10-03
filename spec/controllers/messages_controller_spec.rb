
require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear    

    @person = login_as(:quentin)
    @other_person = people(:aaron)
    @message = @person.received_messages.first
  end

  describe "pages" do
    integrate_views
    
    it "should have a working index" do
      working_page(:index, :received_messages)
    end

    it "should have working sent messages" do
      working_page(:sent, :sent_messages)
    end

    it "should have working trashed messages" do
      working_page(:trash, :trashed_messages)
    end
    
    it "should have a working show page" do
      get :show, :id => @message
      response.should be_success
      response.should render_template("show")
    end
    
    it "should have a working new page" do
      get :new, :person_id => @person
      response.should be_success
      response.should render_template("new")
    end
    
    it "should have a working reply page" do
      proper_reply_behavior(@message.recipient)
    end
    
    it "should have a working reply page for the recipient" do
      # This spec tests replying to your *own* message, as at
      # the bottom of a thread.
      proper_reply_behavior(@message.sender)
    end

    it "should reply correctly when logged in as the sender" do
      login_as @message.sender
      get :reply, :id => @message
      assigns(:recipient).should == @message.recipient
    end
    
    it "should handle invalid reply creation" do
      login_as(:kelly)
      post :create, :message => { :parent_id => @message.id },
                    :person_id => @person
      response.should redirect_to(home_url)
    end
    
    it "should create a message" do
      lambda do
        post :create, :message => { :subject => "The subject",
                                    :content => "Hey there!" },
                      :person_id => @other_person
      end.should change(Message, :count).by(1)
    end
    
    it "should send a message receipt email" do
      lambda do
        post :create, :message => { :subject => "The subject",
                                    :content => "Hey there!" },
                      :person_id => @other_person
      end.should change(@emails, :length).by(1)
    end
    
    it "should handle replies as recipient" do
      handle_replies(@message, @message.recipient, @message.sender)
    end
    
    it "should handle replies as sender" do
      handle_replies(@message, @message.sender, @message.recipient)
    end
    
    it "should trash messages" do
      delete :destroy, :id => @message
      assigns(:message).should be_trashed(@message.recipient)
      assigns(:message).should_not be_trashed(@message.sender)
    end
    
    it "should untrash messages" do
      delete :destroy, :id => @message
      put :undestroy, :id => @message
      assigns(:message).should_not be_trashed(@message.recipient)
    end
    
    it "should require login" do
      logout
      get :index
      response.should redirect_to(login_url)
    end
  end
  
  
  private

    def working_page(page, message_type)
      get page      
      response.should be_success
      response.should render_template("index")
      assigns(:messages).should == @person.send(message_type)
    end
  
    def handle_replies(message, recipient, sender)
      login_as(recipient)
      lambda do
        post :create, :message => { :subject => "The subject",
                                    :content => "This is a reply",
                                    :parent_id  => message.id },
                      :person_id => sender
        assigns(:message).should be_reply
      end.should change(Message, :count).by(1)
    end
  
    def proper_reply_behavior(person)
      login_as person
      get :reply, :id => @message
      response.should be_success
      # Check that the hidden parent_id tag is there, with the right value.
      response.should have_tag("input[id=?][name=?][type=?][value=?]",
                               "message_parent_id",
                               "message[parent_id]",
                               "hidden",
                               @message.id)
      response.should render_template("new")
      assigns(:message).parent.should == @message
      assigns(:recipient).should == @message.other_person(person)
    end
end