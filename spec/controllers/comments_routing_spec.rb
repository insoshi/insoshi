require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  describe "route generation" do

    it "should map { :controller => 'comments', :action => 'index' } to /comments" do
      route_for(:controller => "comments", :action => "index").should == "/comments"
    end
  
    it "should map { :controller => 'comments', :action => 'new' } to /comments/new" do
      route_for(:controller => "comments", :action => "new").should == "/comments/new"
    end
  
    it "should map { :controller => 'comments', :action => 'show', :id => 1 } to /comments/1" do
      route_for(:controller => "comments", :action => "show", :id => 1).should == "/comments/1"
    end
  
    it "should map { :controller => 'comments', :action => 'edit', :id => 1 } to /comments/1/edit" do
      route_for(:controller => "comments", :action => "edit", :id => 1).should == "/comments/1/edit"
    end
  
    it "should map { :controller => 'comments', :action => 'update', :id => 1} to /comments/1" do
      route_for(:controller => "comments", :action => "update", :id => 1).should == "/comments/1"
    end
  
    it "should map { :controller => 'comments', :action => 'destroy', :id => 1} to /comments/1" do
      route_for(:controller => "comments", :action => "destroy", :id => 1).should == "/comments/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'comments', action => 'index' } from GET /comments" do
      params_from(:get, "/comments").should == {:controller => "comments", :action => "index"}
    end
  
    it "should generate params { :controller => 'comments', action => 'new' } from GET /comments/new" do
      params_from(:get, "/comments/new").should == {:controller => "comments", :action => "new"}
    end
  
    it "should generate params { :controller => 'comments', action => 'create' } from POST /comments" do
      params_from(:post, "/comments").should == {:controller => "comments", :action => "create"}
    end
  
    it "should generate params { :controller => 'comments', action => 'show', id => '1' } from GET /comments/1" do
      params_from(:get, "/comments/1").should == {:controller => "comments", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'comments', action => 'edit', id => '1' } from GET /comments/1;edit" do
      params_from(:get, "/comments/1/edit").should == {:controller => "comments", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'comments', action => 'update', id => '1' } from PUT /comments/1" do
      params_from(:put, "/comments/1").should == {:controller => "comments", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'comments', action => 'destroy', id => '1' } from DELETE /comments/1" do
      params_from(:delete, "/comments/1").should == {:controller => "comments", :action => "destroy", :id => "1"}
    end
  end
end