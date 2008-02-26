require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  integrate_views
  
  before(:each) do
    @person = login_as(:quentin)
    @forum = forums(:one)
    @topic = topics(:one)
  end
  
  it "should require login" do
    logout
    get :index
    response.should redirect_to(login_url)
  end
  
  it "should have working pages" do
    with_options :forum_id => @forum, :topic_id => @topic do |page|
      page.get    :index
      page.get    :new
      page.get    :show,    :id => posts(:one)
      page.get    :edit,    :id => posts(:one)
      page.post   :create,  :post => { :body => "The body" }
      page.put    :update,  :id => posts(:one)
      page.delete :destroy, :id => posts(:one)
    end
  end
  
  it "should associate a person to a post" do
    with_options :forum_id => @forum, :topic_id => @topic do |page|
      page.post :create, :post => { :body => "The body" }
      assigns(:post).person.should == @person
    end
  end

  it "should create a post" do
    lambda do
      post :create, :forum_id => @forum, :topic_id => @topic,
                    :post => { :body => "The body" }
      response.should redirect_to(forum_topic_posts_url(@forum, @topic))
    end.should change(Post, :count).by(1)
  end

end