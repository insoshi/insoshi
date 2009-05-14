require File.dirname(__FILE__) + '/../../spec_helper'

describe "login page" do
  
  before(:each) do
    @global_prefs = Preference.find(:first)
  end
  
  it "should have a password reminder link when app can send email" do
    @global_prefs.should be_can_send_email
    render "/sessions/new.html.erb"
    response.should have_tag("a[href=?]", new_password_reminder_path)
  end
  
  it "should not have a password reminder link when app can't send email" do
    @global_prefs.update_attributes!(:email_notifications => false,
                                     :email_verifications => false,
                                     :domain  => "")
    render "/sessions/new.html.erb"
    @global_prefs.should_not be_can_send_email
    response.should_not have_tag("a[href=?]", new_password_reminder_path)
  end
end
