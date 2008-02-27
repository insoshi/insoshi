require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do

  describe "forum posts" do
    integrate_views
  
    before(:each) do
      @person = login_as(:quentin)
      @forum  = forums(:one)
      @topic  = topics(:one)
      @post   = posts(:forum)
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
        page.get    :edit,    :id => @post
        page.post   :create,  :post => { }
        page.put    :update,  :id => @post
        page.delete :destroy, :id => @post
      end
    end

    it "should create a forum post" do
      lambda do
        post :create, :forum_id => @forum, :topic_id => @topic,
                      :post => { :body => "The body" }
        response.should redirect_to(forum_topic_posts_url(@topic))
      end.should change(ForumPost, :count).by(1)
    end
  
    it "should associate a person to a post" do
      with_options :forum_id => @forum, :topic_id => @topic do |page|
        page.post :create, :post => { :body => "The body" }
        assigns(:post).person.should == @person
      end
    end
    it "should render the new template on creation failure" do
      post :create, :forum_id => @forum, :topic_id => @topic,
                          :post => { :body => "" }
      response.should render_template("forum_new")
    end
  end
  
  describe "blog posts" do
    integrate_views
  
    before(:each) do
      @person = login_as(:quentin)
      @blog   = @person.blog
      @post   = posts(:blog)
    end
  
    it "should have working pages" do
      with_options :blog_id => @blog do |page|
        page.get    :index
        page.get    :new
        page.get    :show,    :id => @post
        page.get    :edit,    :id => @post
        page.post   :create,  :post => { }
        page.put    :update,  :id => @post
        page.delete :destroy, :id => @post
      end
    end
    
    it "should create a blog post" do
      lambda do
        post :create, :blog_id => @blog,
                      :post => { :title => "The post", :body => "The body" }
        response.should redirect_to(blog_post_url(@blog, assigns(:post)))
      end.should change(BlogPost, :count).by(1)
    end
    
    it "should create the right blog post associations" do
      lambda do
        post :create, :blog_id => @blog,
                      :post => { :title => "The post", :body => "The body" }
        assigns(:post).blog.should == @blog
      end 
    end
    
    it "should render the new template on creation failure" do
      post :create, :blog_id => @blog, :post => {}
      response.should render_template("blog_new")
    end
  end
end