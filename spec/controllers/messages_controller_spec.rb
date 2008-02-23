require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before(:each) do
    @person = login_as(:quentin)
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
  end
  

  def working_page(page, message_type)
    get page      
    response.should be_success
    response.should render_template("index")
    assigns(:messages).should == @person.send(message_type)
  end

end