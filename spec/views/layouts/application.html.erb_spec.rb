require File.dirname(__FILE__) + '/../../spec_helper'

describe "layout when not logged in" do
  before(:each) do
    render "/layouts/application.html.erb"
  end
  
  it "should have the right DOCTYPE declaration" do
    response.body.should match(/XHTML 1.0 Strict/)
  end
  
  it "should have a login link" do
    response.should have_tag("a[href=?]", login_path)
  end
  
  it "should have a signup link" do
    response.should have_tag("a[href=?]", signup_path)
  end
  
  it "should not have a sign out link" do
    response.should_not have_tag("a[href=?]", logout_path)
  end
  
  it "should have the right analytics" do
    response.should have_tag("script", "Google analytics")
  end
end

describe "layout when logged in" do
  
  before(:each) do
    @person = login_as :quentin
    render "/layouts/application.html.erb"
  end
  
  it "should not have a login link" do
    response.should_not have_tag("a[href=?]", login_path)
  end
  
  it "should not have a signup link" do
    response.should_not have_tag("a[href=?]", signup_path)
  end
  
  it "should have a sign out link" do
    response.should have_tag("a[href=?]", logout_path)
  end
  
  it "should have a profile link" do
    response.should have_tag("a[href=?]", person_path(@person))
  end
end