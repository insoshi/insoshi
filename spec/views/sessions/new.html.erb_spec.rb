require File.dirname(__FILE__) + '/../../spec_helper'

describe "login view" do
  before(:each) do
    render "/sessions/new.html.erb"
  end
  
  it "should render successfully" do
    response.should be_success
  end
end