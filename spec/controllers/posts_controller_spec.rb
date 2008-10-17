require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  include BlogsHelper

  describe "forum posts" do
    integrate_views
  
    before(:each) do
      @person = login_as(:quentin)
      @forum  = forums(:one)
      @topic  = topics(:one)
      @post   = posts(:forum)
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
        topics = forum_topic_url(@forum, @topic, :posts => 2)
        response.should redirect_to(topics)
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
    
    it "should require the right user for editing" do
      person = login_as(:aaron)
      @post.person.should_not == person
      get :edit, :forum_id => @forum, :topic_id => @topic, :id => @post
      response.should redirect_to(home_url)
    end
    
    it "should allow admins to destroy posts" do
      admin!(@person)
      @person.should be_admin
      lambda do
        delete :destroy, :forum_id => @forum, :topic_id => @topic,
                         :id => @post
        response.should redirect_to(forum_topic_url(@forum, @topic))
      end.should change(ForumPost, :count).by(-1)
    end
    
    it "should not allow non-admins to destroy posts" do
      login_as :aaron
      delete :destroy, :forum_id => @forum, :topic_id => @topic,
                       :id => @post
      response.should redirect_to(home_url)
    end
  end
  
  describe "blog posts" do
    integrate_views
  
    before(:each) do
      @person = login_as(:quentin)
      @blog   = @person.blog
      @post   = posts(:blog_post)
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
    
    it "should require the right user to show a blog post" do
      person = login_as(:aaron)
      aarons_blog = person.blog
      quentins_post = @post
      get :show, :blog_id => aarons_blog, :id => quentins_post
      response.should be_redirect
    end
    
    it "should require the right user to create a blog post" do
      login_as :aaron
      post :create, :blog_id => @blog,
                    :post => { :title => "The post", :body => "The body" }
      response.should be_redirect
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
    
    it "should require the right user for editing" do
      person = login_as(:aaron)
      @post.blog.person.should_not == person
      get :edit, :blog_id => @blog, :id => @post
      response.should redirect_to(home_url)
    end
    
    it "should require the post being edited to belong to the blog" do
      wrong_blog = blogs(:two)
      wrong_blog.should_not == @blog
      get :edit, :blog_id => wrong_blog, :id => @post
      response.should redirect_to(home_url)      
    end
    
    it "should destroy a post" do
      delete :destroy, :blog_id => @blog, :id => @post
      @post.should_not exist_in_database
      response.should redirect_to(blog_tab_url(@blog))
    end
    
    it "should require the right user for destroying" do
      person = login_as(:aaron)
      @post.blog.person.should_not == person
      delete :destroy, :blog_id => @blog, :id => @post
      response.should redirect_to(home_url)
    end
  end
end