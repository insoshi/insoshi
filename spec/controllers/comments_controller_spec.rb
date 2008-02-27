require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  
  describe "blog comments" do
    integrate_views
  
    before(:each) do
      @commenter = login_as(:aaron)
      @blog   = people(:quentin).blog
      @post   = posts(:blog)
    end
  
    it "should have working pages" do
      with_options :blog_id => @blog, :post_id => @post do |page|
        page.get    :new
        page.post   :create,  :comment => { }
        page.delete :destroy, :id => comments(:two)
      end
    end
    
    it "should create a blog comment" do
      lambda do
        post :create, :blog_id => @blog, :post_id => @post,
                      :comment => { :body => "The body" }
        response.should redirect_to(blog_post_url(@blog, @post))
      end.should change(BlogPostComment, :count).by(1)
    end
    
    it "should create the right blog comment associations" do
      lambda do
        post :create, :blog_id => @blog, :post_id => @post,
                      :post => { :body => "The body" }
        assigns(:comment).commenter.should == @commenter
        assigns(:comment).post.should == @post
      end 
    end
    
    it "should render the new template on creation failure" do
      post :create, :blog_id => @blog, :post_id => @post, :comment => {}
      response.should render_template("blog_post_new")
    end
  end

  
  describe "wall comments" do
    integrate_views
  
    before(:each) do
      @commenter = login_as(:aaron)
      @person    = people(:quentin)
    end
  
    it "should have working pages" do
      with_options :person_id => @person do |page|
        page.get    :new
        page.post   :create,  :comment => { }
        page.delete :destroy, :id => comments(:one)
      end
    end
  
    it "should create a wall comment" do
      lambda do
        post :create, :person_id => @person,
                      :comment => { :body => "The body" }
        response.should redirect_to(person_url(@person))
      end.should change(WallComment, :count).by(1)
    end
      
    it "should associate a person to a comment" do
      with_options :person_id => @person do |page|
        page.post :create, :comment => { :body => "The body" }
        assigns(:comment).commenter.should == @commenter
        assigns(:comment).person.should == @person
      end
    end
    
    it "should render the new template on creation failure" do
      post :create, :person_id => @person, :comment => { :body => "" }
      response.should render_template("wall_new")
    end
  end
end