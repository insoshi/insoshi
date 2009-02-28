require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  integrate_views

  before(:each) do
    @topic = topics(:one)
  end
  
  it "should require login for new" do
    get :new
    response.should redirect_to(login_url)
  end
  
  it "should have working pages" do
    login_as :quentin
    
    with_options :forum_id => forums(:one) do |page|
      page.get    :new
      page.get    :edit,    :id => @topic
      page.post   :create,  :topic => { :name => "The topic" }
      page.put    :update,  :id => @topic
      page.delete :destroy, :id => @topic
    end
  end  
  
  it "should associate a person to a topic" do
    person = login_as(:quentin)
    with_options :forum_id => forums(:one) do |page|
      page.post :create, :topic => { :name => "The topic" }
      assigns(:topic).person.should == person
    end
  end
  
  it "should redirect properly on topic deletion" do
    person = login_as(:admin)
    @forum = Forum.find(@topic.forum)
    delete :destroy, :id => @topic, :forum_id => @forum
    response.should redirect_to(forum_url(@forum))
  end
  
end
