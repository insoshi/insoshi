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
      @primary, @secondary = [mock_photo(:primary => true), mock_photo]
      photos = [@primary, @secondary]
      photos.each { |p| p.stub!(:person).and_return(@person) }
      @photo = @primary
      @person.stub!(:photos).and_return([@primary, @secondary])
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
      Photo.should_receive(:find).and_return(@photo)
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
    
    it "should handle cancellation" do
      post :create, :commit => "Cancel"
      response.should redirect_to(edit_person_url(@person))
    end
    
    it "should mark a photo as primary" do
      # We check that the secondary photo is made primary, while the old
      # primary photo is marked non-primary.
      Photo.should_receive(:find).and_return(@secondary)
      @secondary.should_receive(:update_attributes).with(:primary => true).
        and_return(true)
      @primary.should_receive(:update_attributes!).with(:primary => false)
      put :update, :photo => @secondary
    end
    
    it "should destroy a photo" do
      Photo.should_receive(:find).and_return(@secondary)
      @secondary.should_receive(:destroy).and_return(true)
      delete :destroy, :id => @secondary
    end
    
    it "should mark another photo as primary if destroying primary" do
      Photo.should_receive(:find).and_return(@primary)
      @primary.should_receive(:destroy).and_return(true)
      @secondary.should_receive(:update_attributes!).with(:primary => true)
      delete :destroy, :id => @primary
    end
    
    it "should require the correct user to edit" do
      login_as :aaron
      Photo.should_receive(:find).and_return(@photo)
      get :edit, :id => @photo
      response.should redirect_to(home_url)
    end
  end
end
