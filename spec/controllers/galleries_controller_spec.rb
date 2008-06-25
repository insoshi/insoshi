require File.dirname(__FILE__) + '/../spec_helper'

describe GalleriesController do
  describe "when not logged in" do
      
    it "should protect the index page" do
      get :index
      response.should redirect_to(login_url)
    end
  end
  
  describe "when logged in" do
    integrate_views
  
    before(:each) do
      @gallery = galleries(:valid_gallery)
      @person  = people(:quentin)
      login_as(:quentin)
    end
    
    it "should have working pages" do |page|
      page.get    :index,   :person_id => @person   
      response.should be_success
      
      page.get    :show,    :id => @gallery        
      response.should be_success
      
      page.get    :new                              
      response.should be_success
      
      page.get    :edit,    :id => @gallery
      response.should be_success
      
      page.delete :destroy, :id => @gallery
      @gallery.should_not exist_in_database
    end
    
    it "should associate person to the gallery" do
      post :create, :gallery => {:title=>"Title"}
      assigns(:gallery).person.should == @person
    end
    
    it "should require the correct user to edit" do
      login_as(:kelly)
      post :edit, :id => @gallery
      response.should redirect_to(person_galleries_url(@person))
    end
    
    it "should require the correct user to delete" do
      login_as(:kelly)
      delete :destroy, :id => @gallery
      response.should redirect_to(person_galleries_url(@person))
    end
  end
end
