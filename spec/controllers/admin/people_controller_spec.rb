require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PeopleController do
  
  it "should redirect a non-logged-in user" do
    get :index
    response.should be_redirect
  end
  
  it "should redirect a non-admin user" do
    login_as :aaron
    get :index
    response.should be_redirect
  end

  it "should render successfully for an admin user" do
    login_as :quentin
    get :index
    response.should be_success
  end
  
  describe "person modifications" do
    
    before(:each) do
      @admin = login_as(:quentin)
      @person = people(:aaron)
    end
    
    it "should deactivate a person" do
      @person.should_not be_deactivated
      put :update, :id => @person, :task => "deactivate"
      Person.find(@person).should be_deactivated
    end
    
    it "should reactivate a person" do
      @person.toggle(:deactivated)
      @person.save!
      @person.should be_deactivated
      put :update, :id => @person, :task => "deactivate"
      Person.find(@person).should_not be_deactivated
    end
  end
  
end
