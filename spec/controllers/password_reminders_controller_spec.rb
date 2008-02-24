require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordRemindersController do
  integrate_views
  
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear    
    @person = people(:quentin)
  end
  
  it "should render the new email reminder page" do
    get :new
    response.should be_success
    response.should render_template("new")
  end
  
  it "should deliver a reminder" do
    lambda do
      post :create, :person => { :email => @person.email }
      response.should be_redirect
    end.should change(@emails, :length).by(1)
  end
end
