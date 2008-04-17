require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do

  before(:each) do
    @person = people(:quentin)
    photos = [mock_photo(:primary => true), mock_photo]
    photos.stub!(:find_all_by_primary).and_return(photos.select(&:primary?))
    @person.stub!(:photos).and_return(photos)
    login_as(:aaron)
  end
  
  describe "people pages" do
    integrate_views
    
    it "should require login" do
      logout
      get :index
      response.should redirect_to(login_url)
    end
    
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
    
    it "should allow non-logged-in users to view new page" do
      logout
      get :new
      response.should be_success
    end
    
    it "should have a working show page" do
      get :show, :id => @person
      response.should be_success
      response.should render_template("show")
    end
    
    it "should have a working edit page" do
      login_as @person
      get :edit, :id => @person
      response.should be_success
      response.should render_template("edit")
    end
  end
  
  describe "create" do
    before(:each) do
      logout
    end

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
    
    describe "email validations" do
      
      before(:each) do
        @preferences = preferences(:one)
      end
      
      it "should create an active user if not verifying email" do
        create_person
        assigns(:person).should_not be_deactivated
      end
    
      it "should create a deactivated person if verifying email" do
        @preferences.email_verifications?.should be_false
        @preferences.toggle!(:email_verifications)
        create_person
        assigns(:person).should be_deactivated
      end
    end
  end
  
  describe "edit" do
    integrate_views
    
    before(:each) do
      @person = login_as(:quentin)
    end
    
    it "should render the edit page when photos are present" do
      get :edit, :id => @person
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should allow mass assignment to name" do
      put :update, :id => @person, :person => { :name => "Foo Bar" },
                   :type => "info_edit"
      assigns(:person).name.should == "Foo Bar"
      response.should redirect_to(person_url(assigns(:person)))
    end
      
    it "should allow mass assignment to description" do
      put :update, :id => @person, :person => { :description => "Me!" },
                   :type => "info_edit"
      assigns(:person).description.should == "Me!"
      response.should redirect_to(person_url(assigns(:person)))
    end
    
    it "should render edit page on invalid update" do
      put :update, :id => @person, :person => { :email => "foo" },
                   :type => "info_edit"
      response.should be_success
      response.should render_template("edit")
    end
    
    it "should require the right authorized user" do
      login_as(:aaron)
      put :update, :id => @person
      response.should redirect_to(home_url)
    end
    
    it "should change the password" do
      current_password = @person.unencrypted_password
      newpass = "dude"
      put :update, :id => @person,
                   :person => { :verify_password => current_password,
                                :new_password => newpass,
                                :password_confirmation => newpass },
                   :type => "password_edit"
      response.should redirect_to(person_url(@person))
    end
  end
  
  describe "show" do
    integrate_views    
    
    it "should display the edit link for current user" do
      login_as @person
      get :show, :id => @person
      response.should have_tag("a[href=?]", edit_person_path(@person))
    end
    
    it "should not display the edit link for other viewers" do
      login_as(:aaron)
      get :show, :id => @person
      response.should_not have_tag("a[href=?]", edit_person_path(@person))
    end
    
    it "should not display the edit link for non-logged-in viewers" do
      logout
      get :show, :id => @person
      response.should_not have_tag("a[href=?]", edit_person_path(@person))
    end
    
    it "should not display a deactivated person" do
      @person.toggle!(:deactivated)
      get :show, :id => @person
      @response.should redirect_to(home_url)
    end
  end
  
  private

    def create_person(options = {})
      post :create, :person => { :name => "Quire",:email => 'quire@foo.com',
        :password => 'quux', :password_confirmation => 'quux' }.merge(options)
    end
end