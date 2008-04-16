require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PreferencesController do

  describe "authentication" do
    it "should require admin to access" do
      login_as :quentin
      get :index
      response.should redirect_to(home_url)
    end
  
    it "should allow an admin to access" do
      login_as :admin
      get :index
      response.should be_success
    end
  end

  describe "changing preferences" do
    integrate_views
    
    before(:each) do
      @preferences = Preference.find(:first)
      login_as :admin
    end
    
    it "should render messages for email notification error" do
      put :update, :preferences => { :smtp_server => "", :email_domain => "", 
                                     :email_notifications => "1" }
      response.body.should =~ /errorExplanation/
    end
    
    it "should update email notifications" do
      @preferences.email_notifications = false
      @preferences.save!
      @preferences.email_notifications.should be_false
      put :update, :preferences => { :smtp_server => "smtp.server",
                                     :email_domain => "example.com", 
                                     :email_notifications => "1" }
      @preferences.reload.email_notifications.should be_true
    end
    
    it "should have a flash warning if the SMTP server changes" 
    it "should have a flash warning if the email domain changes" 
  end
end