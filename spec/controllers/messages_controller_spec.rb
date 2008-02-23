require File.dirname(__FILE__) + '/../spec_helper'

describe MessagesController do

  before(:each) do
    @person = login_as(:quentin)
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
  end

  def working_page(page, message_type)
    get page      
    response.should be_success
    response.should render_template("index")
    assigns(:messages).should == @person.send(message_type)
  end

end