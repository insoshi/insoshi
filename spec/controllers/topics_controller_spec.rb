require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  integrate_views
  
  it "should require login" do
    get :index
    response.should redirect_to(login_url)
  end
  
  it "should have working pages" do
    login_as :quentin
    
    with_options :forum_id => forums(:one) do |page|
      page.get    :index
      page.get    :new
      page.get    :edit,    :id => topics(:one)
      page.post   :create,  :topic => { :name => "Foobar" }
      page.put    :update,  :id => topics(:one)
      page.delete :destroy, :id => topics(:one)
    end
  end
end