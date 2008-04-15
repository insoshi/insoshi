require File.dirname(__FILE__) + '/../spec_helper'

describe PreferencesController do
  describe "route generation" do

    it "should map { :controller => 'preferences', :action => 'index' } to /preferences" do
      route_for(:controller => "preferences", :action => "index").should == "/preferences"
    end
  
    it "should map { :controller => 'preferences', :action => 'new' } to /preferences/new" do
      route_for(:controller => "preferences", :action => "new").should == "/preferences/new"
    end
  
    it "should map { :controller => 'preferences', :action => 'show', :id => 1 } to /preferences/1" do
      route_for(:controller => "preferences", :action => "show", :id => 1).should == "/preferences/1"
    end
  
    it "should map { :controller => 'preferences', :action => 'edit', :id => 1 } to /preferences/1/edit" do
      route_for(:controller => "preferences", :action => "edit", :id => 1).should == "/preferences/1/edit"
    end
  
    it "should map { :controller => 'preferences', :action => 'update', :id => 1} to /preferences/1" do
      route_for(:controller => "preferences", :action => "update", :id => 1).should == "/preferences/1"
    end
  
    it "should map { :controller => 'preferences', :action => 'destroy', :id => 1} to /preferences/1" do
      route_for(:controller => "preferences", :action => "destroy", :id => 1).should == "/preferences/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'preferences', action => 'index' } from GET /preferences" do
      params_from(:get, "/preferences").should == {:controller => "preferences", :action => "index"}
    end
  
    it "should generate params { :controller => 'preferences', action => 'new' } from GET /preferences/new" do
      params_from(:get, "/preferences/new").should == {:controller => "preferences", :action => "new"}
    end
  
    it "should generate params { :controller => 'preferences', action => 'create' } from POST /preferences" do
      params_from(:post, "/preferences").should == {:controller => "preferences", :action => "create"}
    end
  
    it "should generate params { :controller => 'preferences', action => 'show', id => '1' } from GET /preferences/1" do
      params_from(:get, "/preferences/1").should == {:controller => "preferences", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'preferences', action => 'edit', id => '1' } from GET /preferences/1;edit" do
      params_from(:get, "/preferences/1/edit").should == {:controller => "preferences", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'preferences', action => 'update', id => '1' } from PUT /preferences/1" do
      params_from(:put, "/preferences/1").should == {:controller => "preferences", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'preferences', action => 'destroy', id => '1' } from DELETE /preferences/1" do
      params_from(:delete, "/preferences/1").should == {:controller => "preferences", :action => "destroy", :id => "1"}
    end
  end
end