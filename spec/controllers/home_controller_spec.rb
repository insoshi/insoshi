require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  integrate_views
  
  before(:each) do
    login_as :quentin
    get :index
  end
  
  it "should have a feed" do
    response.should have_tag("th", /feed/i)
  end
  
  it "should have a logo div" do
    response.should have_tag("div[id=?]", "logo")
  end
  
  it "should have a main column" do
    response.should have_tag("div[class=?]",
                             "column first last span-#{FULL}")
  end
  
  it "should have a primary div" do
    response.should have_tag("div[class=?]",
                             "column first span-#{LEFT}")
  end
  
  it "should have a secondary div" do
    response.should have_tag("div[class=?]",
                             "column last span-#{RIGHT}")
  end
end
