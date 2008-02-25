require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController do
  describe "route generation" do

    it "should map { :controller => 'forums', :action => 'index' } to /forums" do
      route_for(:controller => "forums", :action => "index").should == "/forums"
    end
  
    it "should map { :controller => 'forums', :action => 'new' } to /forums/new" do
      route_for(:controller => "forums", :action => "new").should == "/forums/new"
    end
  
    it "should map { :controller => 'forums', :action => 'show', :id => 1 } to /forums/1" do
      route_for(:controller => "forums", :action => "show", :id => 1).should == "/forums/1"
    end
  
    it "should map { :controller => 'forums', :action => 'edit', :id => 1 } to /forums/1/edit" do
      route_for(:controller => "forums", :action => "edit", :id => 1).should == "/forums/1/edit"
    end
  
    it "should map { :controller => 'forums', :action => 'update', :id => 1} to /forums/1" do
      route_for(:controller => "forums", :action => "update", :id => 1).should == "/forums/1"
    end
  
    it "should map { :controller => 'forums', :action => 'destroy', :id => 1} to /forums/1" do
      route_for(:controller => "forums", :action => "destroy", :id => 1).should == "/forums/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'forums', action => 'index' } from GET /forums" do
      params_from(:get, "/forums").should == {:controller => "forums", :action => "index"}
    end
  
    it "should generate params { :controller => 'forums', action => 'new' } from GET /forums/new" do
      params_from(:get, "/forums/new").should == {:controller => "forums", :action => "new"}
    end
  
    it "should generate params { :controller => 'forums', action => 'create' } from POST /forums" do
      params_from(:post, "/forums").should == {:controller => "forums", :action => "create"}
    end
  
    it "should generate params { :controller => 'forums', action => 'show', id => '1' } from GET /forums/1" do
      params_from(:get, "/forums/1").should == {:controller => "forums", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'forums', action => 'edit', id => '1' } from GET /forums/1;edit" do
      params_from(:get, "/forums/1/edit").should == {:controller => "forums", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'forums', action => 'update', id => '1' } from PUT /forums/1" do
      params_from(:put, "/forums/1").should == {:controller => "forums", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'forums', action => 'destroy', id => '1' } from DELETE /forums/1" do
      params_from(:delete, "/forums/1").should == {:controller => "forums", :action => "destroy", :id => "1"}
    end
  end
end