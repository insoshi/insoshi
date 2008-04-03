require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ForumsController do
  it "should restrict forum modifications to admins" do
    not_admin = login_as(:aaron)
    get :new
    response.should redirect_to(home_url)
  end
  
  it "should allow admin to access a modification page" do
    admin = admin!(login_as(:quentin))
    get :new
    response.should be_success    
  end
end
