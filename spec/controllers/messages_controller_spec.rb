require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before(:each) do
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
    
    it "should have a working new page" do
      get :new, :person_id => @person
      response.should be_success
      response.should render_template("new")
    end
    
    it "should have a working reply page" do
      login_as @message.recipient
      get :reply, :id => @message
      response.should be_success
      response.should render_template("new")
      assigns(:message).parent.should == @message
      assigns(:recipient).should == @message.sender
    end

    it "should reply correctly when logged in as the sender" do
      login_as @message.sender
      get :reply, :id => @message
      assigns(:recipient).should == @message.recipient
    end
    
    it "should allow create cancellation" do
      post :create, :commit => "Cancel"
      response.should redirect_to(messages_url)
    end
    
    it "should handle invalid reply creation" do
      login_as(:kelly)
      post :create, :parent_id => @message, :person_id => @person
      response.should redirect_to(home_url)
    end
    
    it "should create a message" do
      lambda do
        post :create, :message => { :content => "Hey there!" },
                      :person_id => @other_person
      end.should change(Message, :count).by(1)
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
      post :create, :message => { :content   => "This is a reply",
                                  :parent_id => message },
                    :person_id => sender
      assigns(:message).should be_reply
    end.should change(Message, :count).by(1)
  end
end