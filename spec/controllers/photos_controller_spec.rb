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
      @person = login_as(:quentin)
      @gallery = galleries(:valid_gallery)
      @primary, @secondary = [mock_photo(:primary => true, :gallery => @gallery), mock_photo(:gallery => @gallery)]
      photos = [@primary, @secondary]
      photos.each { |p| p.stub!(:person).and_return(@person) }
      @photo = @primary
      @person.stub!(:photos).and_return([@primary, @secondary])
    end
  
    
    it "should have a new photo page" do
      get :new, :gallery_id => @gallery
      response.should be_success
      response.should render_template("new")
    end
    
    it "should not have a new photo page without given gallery id" do
      get :new
      response.should_not be_success
    end

    it "should have an edit photo page" do
      Photo.should_receive(:find).and_return(@photo)
      get :edit, :id => @photo
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should create photo" do
      image = uploaded_file("rails.png")
      lambda do
        post :create, :photo => { :uploaded_data => image}, :gallery_id => @gallery
      end.should change(Photo, :count).by(1)
    end
    
    it "should handle empty photo upload" do
      lambda do
        post :create, :photo => { :uploaded_data => nil }, :gallery_id => @gallery
        response.should render_template("new")
      end.should_not change(Photo, :count)
    end
    
    it "should handle cancellation and doesn't report about problem" do
      post :create, :commit => "Cancel", :photo => { :uploaded_data => nil }, :gallery_id => @gallery
      response.should redirect_to(gallery_url(@gallery))
      flash[:error].should be_nil
    end
    
    it "should handle nil photo parameter" do
      post :create, :photo => nil, :gallery_id => @gallery
      response.should redirect_to(gallery_url(@gallery))
      flash[:error].should_not be_nil
    end
    
    it "should destroy a photo" do
      Photo.should_receive(:find).and_return(@secondary)
      @secondary.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @secondary
    end
    
    it "should require the correct user to edit" do
      login_as :aaron
      Photo.should_receive(:find).and_return(@photo)
      get :edit, :id => @photo
      response.should redirect_to(home_url)
    end
  end
end
