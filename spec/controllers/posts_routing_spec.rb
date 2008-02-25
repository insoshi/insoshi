require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  describe "route generation" do

    it "should map { :controller => 'posts', :action => 'index' } to /posts" do
      route_for(:controller => "posts", :action => "index").should == "/posts"
    end
  
    it "should map { :controller => 'posts', :action => 'new' } to /posts/new" do
      route_for(:controller => "posts", :action => "new").should == "/posts/new"
    end
  
    it "should map { :controller => 'posts', :action => 'show', :id => 1 } to /posts/1" do
      route_for(:controller => "posts", :action => "show", :id => 1).should == "/posts/1"
    end
  
    it "should map { :controller => 'posts', :action => 'edit', :id => 1 } to /posts/1/edit" do
      route_for(:controller => "posts", :action => "edit", :id => 1).should == "/posts/1/edit"
    end
  
    it "should map { :controller => 'posts', :action => 'update', :id => 1} to /posts/1" do
      route_for(:controller => "posts", :action => "update", :id => 1).should == "/posts/1"
    end
  
    it "should map { :controller => 'posts', :action => 'destroy', :id => 1} to /posts/1" do
      route_for(:controller => "posts", :action => "destroy", :id => 1).should == "/posts/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'posts', action => 'index' } from GET /posts" do
      params_from(:get, "/posts").should == {:controller => "posts", :action => "index"}
    end
  
    it "should generate params { :controller => 'posts', action => 'new' } from GET /posts/new" do
      params_from(:get, "/posts/new").should == {:controller => "posts", :action => "new"}
    end
  
    it "should generate params { :controller => 'posts', action => 'create' } from POST /posts" do
      params_from(:post, "/posts").should == {:controller => "posts", :action => "create"}
    end
  
    it "should generate params { :controller => 'posts', action => 'show', id => '1' } from GET /posts/1" do
      params_from(:get, "/posts/1").should == {:controller => "posts", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'posts', action => 'edit', id => '1' } from GET /posts/1;edit" do
      params_from(:get, "/posts/1/edit").should == {:controller => "posts", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'posts', action => 'update', id => '1' } from PUT /posts/1" do
      params_from(:put, "/posts/1").should == {:controller => "posts", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'posts', action => 'destroy', id => '1' } from DELETE /posts/1" do
      params_from(:delete, "/posts/1").should == {:controller => "posts", :action => "destroy", :id => "1"}
    end
  end
end