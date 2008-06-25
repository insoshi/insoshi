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
      # @primary, @secondary = [mock_photo(:primary => true, :gallery => @gallery, :title=>"snsi"), mock_photo(:gallery => @gallery, :title => nil)]
      # photos = [@primary, @secondary]
      # photos.each { |p| p.stub!(:person).and_return(@person) }
      # @person.stub!(:photos).and_return([@primary, @secondary])
      
      @filename = "rails.png"
      @image = uploaded_file(@filename, "image/png")
      @primary = Photo.new({:uploaded_data => @image, :person => people(:quentin), :gallery => @gallery, :avatar => true, :primary => true})
      @primary.save
      @secondary = Photo.new({:uploaded_data => @image, :person => people(:quentin), :gallery => @gallery, :avatar => false, :primary => false})
      @secondary.save
      @photo = @primary
      
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
    
    it "should be able to set the photo as avatar" do
      put :set_avatar, :id => @secondary.id
      response.should redirect_to(person_galleries_url(@person))
      #assigns(@secondary).avatar.should be_true
      # @primary.avatar.should_not be_true
      @secondary = Photo.find(@secondary.id)
      @secondary.avatar.should be_true
      @primary = Photo.find(@primary.id)
      @primary.avatar.should_not be_true
    end
    
    it "should be able to set the photo as primary for the gallery" do
      put :set_primary, :id => @secondary
      response.should redirect_to(person_galleries_url(@person))
      
      @secondary = Photo.find(@secondary.id)
      @secondary.primary.should be_true
      @primary = Photo.find(@primary.id)
      @primary.primary.should_not be_true
    
    end
  end
end
