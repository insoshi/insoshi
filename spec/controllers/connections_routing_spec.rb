require File.dirname(__FILE__) + '/../spec_helper'

describe ConnectionsController do
  describe "route generation" do

    it "should map { :controller => 'connections', :action => 'index' } to /connections" do
      route_for(:controller => "connections", :action => "index").should == "/connections"
    end
  
    it "should map { :controller => 'connections', :action => 'new' } to /connections/new" do
      route_for(:controller => "connections", :action => "new").should == "/connections/new"
    end
  
    it "should map { :controller => 'connections', :action => 'show', :id => 1 } to /connections/1" do
      route_for(:controller => "connections", :action => "show", :id => 1).should == "/connections/1"
    end
  
    it "should map { :controller => 'connections', :action => 'edit', :id => 1 } to /connections/1/edit" do
      route_for(:controller => "connections", :action => "edit", :id => 1).should == "/connections/1/edit"
    end
  
    it "should map { :controller => 'connections', :action => 'update', :id => 1} to /connections/1" do
      route_for(:controller => "connections", :action => "update", :id => 1).should == "/connections/1"
    end
  
    it "should map { :controller => 'connections', :action => 'destroy', :id => 1} to /connections/1" do
      route_for(:controller => "connections", :action => "destroy", :id => 1).should == "/connections/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'connections', action => 'index' } from GET /connections" do
      params_from(:get, "/connections").should == {:controller => "connections", :action => "index"}
    end
  
    it "should generate params { :controller => 'connections', action => 'new' } from GET /connections/new" do
      params_from(:get, "/connections/new").should == {:controller => "connections", :action => "new"}
    end
  
    it "should generate params { :controller => 'connections', action => 'create' } from POST /connections" do
      params_from(:post, "/connections").should == {:controller => "connections", :action => "create"}
    end
  
    it "should generate params { :controller => 'connections', action => 'show', id => '1' } from GET /connections/1" do
      params_from(:get, "/connections/1").should == {:controller => "connections", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'connections', action => 'edit', id => '1' } from GET /connections/1;edit" do
      params_from(:get, "/connections/1/edit").should == {:controller => "connections", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'connections', action => 'update', id => '1' } from PUT /connections/1" do
      params_from(:put, "/connections/1").should == {:controller => "connections", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'connections', action => 'destroy', id => '1' } from DELETE /connections/1" do
      params_from(:delete, "/connections/1").should == {:controller => "connections", :action => "destroy", :id => "1"}
    end
  end
end