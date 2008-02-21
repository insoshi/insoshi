require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do
  
  describe "signup" do
    integrate_views

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
    
    before(:each) do
      @person = create_person
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
  
    it "should have a working edit page" do
      get :edit, :id => @person
      response.should be_success
    end
  end
  
  def create_person(options = {})
    post :create, :person => { :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end