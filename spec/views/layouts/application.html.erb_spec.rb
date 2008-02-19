require File.dirname(__FILE__) + '/../../spec_helper'

describe "layout when not logged in" do
  before(:each) do
    render "/layouts/application.html.erb"
  end
  
  it "should have the right DOCTYPE declaration" do
    response.body.should match(/XHTML 1.0 Strict/)
  end
  
  it "should have the right CSS includes" do
    %w(screen print lib/ie).each do |filename|
      response.body.should match(/\/stylesheets\/blueprint\/#{filename}.css/)
    end
  end
  
  it "should have a stylesheets with the correct media types" do
    response.should have_tag("link[type=?][media=?]", "text/css", 
                                                      "screen, projection")
    response.should have_tag("link[type=?][media=?]", "text/css", "print")
  end
end