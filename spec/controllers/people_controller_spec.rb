require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do

  before(:each) do
    @person = people(:quentin)
    @photo = mock_model(Photo)
    @photo.stub!(:public_filename).and_return("main photo")
    @person.stub!(:photos).and_return([@photo])
  end
  
  describe "people pages" do
    integrate_views
    
    it "should have a working index" do
      get :index
      response.should be_success
      response.should render_template("index")
    end

    it "should have a working new page" do
      get :new
      response.should be_success
      response.should render_template("new")
    end
    
    it "should have a working show page" do
      Person.should_receive(:find).with(@person).and_return(@person)
      get :show, :id => @person
      response.should be_success
      response.should render_template("show")
    end
        
    it "should have a working edit page" do
      person = login_as(:quentin)
      get :edit, :id => person
      response.should be_success
      response.should render_template("edit")      
    end    
  end
  
  describe "signup" do

    it 'allows signup' do
      lambda do
        create_person
        response.should be_redirect      
      end.should change(Person, :count).by(1)
    end
  
    it 'requires password on signup' do
      lambda do
        create_person(:password => nil)
        assigns[:person].errors.on(:password).should_not be_nil
        response.should be_success
      end.should_not change(Person, :count)
    end
  
    it 'requires password confirmation on signup' do
      lambda do
        create_person(:password_confirmation => nil)
        assigns[:person].errors.on(:password_confirmation).should_not be_nil
        response.should be_success
      end.should_not change(Person, :count)
    end

    it 'requires email on signup' do
      lambda do
        create_person(:email => nil)
        assigns[:person].errors.on(:email).should_not be_nil
        response.should be_success
      end.should_not change(Person, :count)
    end
  end
  
  describe "edit" do
    integrate_views
    
    before(:each) do
      @person = login_as(:quentin)
    end
    
    it "should allow mass assignment to name" do
      put :update, :id => @person, :person => { :name => "Foo Bar" }
      assigns(:current_person).name.should == "Foo Bar"
      response.should redirect_to(person_url(assigns(:current_person)))
    end
  
    it "should allow mass assignment to description" do
      put :update, :id => @person, :person => { :description => "Me!" }
      assigns(:current_person).description.should == "Me!"
      response.should redirect_to(person_url(assigns(:current_person)))
    end
    
    it "should render edit page on invalid update" do
      put :update, :id => @person, :person => { :email => "foo" }
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should require the right authorized user" do
      login_as(:aaron)
      put :update, :id => @person
      response.should redirect_to(home_url)
    end
  end
  
  describe "show" do
    integrate_views
    
    before(:each) do
      # WARNING: calling this *after* the Person.stub! returns Quentin (!)
      # instead of Aaron, since people() apparently calls find under the hood.
      @aaron = people(:aaron)
      # Needed to get the photo.
      Person.stub!(:find).and_return(@person)
    end
    
    it "should display the edit link for current user" do
      login_as(@person)
      get :show, :id => @person
      assigns[:person].photos = [@photo]
      response.should have_tag("a[href=?]", edit_person_path(@person))
    end
    
    it "should not display the edit link for other viewers" do
      login_as(:aaron)
      Person.should_receive(:find).with(@aaron.id).and_return(@aaron)
      get :show, :id => @person
      response.should_not have_tag("a[href=?]", edit_person_path(@person))
    end
    
    it "should not display the edit link for non-logged-in viewers" do
      logout
      get :show, :id => @person
      response.should_not have_tag("a[href=?]", edit_person_path(@person))
    end
  end
  
  private

    def create_person(options = {})
      post :create, :person => { :email => 'quire@example.com',
        :password => 'quux', :password_confirmation => 'quux' }.merge(options)
    end
end