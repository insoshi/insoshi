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
end
