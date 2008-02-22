require File.dirname(__FILE__) + '/../spec_helper'

describe PhotosController do

  describe "when not logged in" do
      
    it "should protect the index page" do
      get :index
      response.should redirect_to(login_url)
    end
  end

  describe "when logged in" do
    integrate_views
    
    before(:each) do
      @person = login_as :quentin
    end
  
    it "should have an index page" do
      get :index
      response.should be_success
      response.should render_template("index")
    end
  end
  
end
