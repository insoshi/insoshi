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
  
  describe "person modifications" do
    
    before(:each) do
      @admin = login_as(:quentin)
      @person = people(:aaron)
    end
    
    it "should deactivate a person" do
      @person.should_not be_deactivated
      put :update, :id => @person, :task => "deactivated"
      @person.reload.should be_deactivated
    end
    
    it "should reactivate a person" do
      @person.toggle(:deactivated)
      @person.save!
      @person.should be_deactivated
      put :update, :id => @person, :task => "deactivated"
      @person.reload.should_not be_deactivated
    end
    
    
    it "should allow an admin to deactivate himself" do
      @person.toggle!(:admin)
      put :update, :id => @admin, :task => "deactivated"
      @admin.reload.should be_deactivated
    end

    it "should not deactivation if no other admins are active" do
      # Add an admin, but deactivate him.
      @person.toggle!(:admin)
      @person.toggle!(:deactivated)
      put :update, :id => @admin, :task => "deactivated"
      @admin.reload.should_not be_deactivated
    end    
    
    it "should not allow last admin to deactivate himself" do
      put :update, :id => @admin, :task => "deactivated"
      @admin.should_not be_deactivated
    end
    
    it "should allow an admin to un-admin himself" do
      @person.toggle!(:admin)
      put :update, :id => @admin, :task => "admin"
      @admin.reload.should_not be_admin
    end
    it "should not allow the last admin to un-admin himself" do
      put :update, :id => @admin, :task => "admin"
      @admin.reload.should be_admin
    end
  end
  
end
