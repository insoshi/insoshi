require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  integrate_views
  
  it "should require login for new" do
    get :new
    response.should redirect_to(login_url)
  end
  
  it "should have working pages" do
    login_as :quentin
    
    with_options :forum_id => forums(:one) do |page|
      page.get    :index
      page.get    :new
      page.get    :edit,    :id => topics(:one)
      page.post   :create,  :topic => { :name => "The topic" }
      page.put    :update,  :id => topics(:one)
      page.delete :destroy, :id => topics(:one)
    end
  end  
  
  it "should associate a person to a topic" do
    person = login_as(:quentin)
    with_options :forum_id => forums(:one) do |page|
      page.post :create, :topic => { :name => "The topic" }
      assigns(:topic).person.should == person
    end
  end
end