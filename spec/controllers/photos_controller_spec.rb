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
    
    it "should have a new photo page" do
      get :new
      response.should be_success
      response.should render_template("new")
    end

    it "should have an edit photo page" do
      @photo = mock_model(Photo)
      @photo.stub!(:public_filename).with(:thumbnail).and_return("thumb")
      Photo.stub!(:find).and_return(@photo)
      get :edit, :id => @photo
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should create photo" do
      image = uploaded_file("rails.png")
      num_thumbnails = 2
      lambda do
        post :create, :photo => { :uploaded_data => image }
      end.should change(Photo, :count).by(num_thumbnails + 1)
    end
    
    it "should handle empty photo upload" do
      lambda do
        post :create, :photo => { :uploaded_data => nil }
        response.should render_template("new")
      end.should_not change(Photo, :count)
    end
  end
end
