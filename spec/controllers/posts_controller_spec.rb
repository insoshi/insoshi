require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  integrate_views
  
  it "should require login" do
    get :index
    response.should redirect_to(login_url)
  end
  
  it "should have working pages" do
    login_as :quentin
    
    with_options :forum_id => forums(:one), :topic_id => topics(:one) do |page|
      page.get    :index
      page.get    :new
      page.get    :edit,    :id => posts(:one)
      page.post   :create,  :post => { :body => "The body" }
      page.put    :update,  :id => posts(:one)
      page.delete :destroy, :id => posts(:one)
    end
  end
  
  it "should associate a person to a post" do
    person = login_as(:quentin)
    with_options :forum_id => forums(:one), :topic_id => topics(:one) do |page|
      page.post :create, :post => { :body => "The body" }
      assigns(:post).person.should == person
    end
  end
end