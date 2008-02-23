require File.dirname(__FILE__) + '/../spec_helper'

describe CommunicationsController do
  describe "route generation" do

    it "should map { :controller => 'communications', :action => 'index' } to /communications" do
      route_for(:controller => "communications", :action => "index").should == "/communications"
    end
  
    it "should map { :controller => 'communications', :action => 'new' } to /communications/new" do
      route_for(:controller => "communications", :action => "new").should == "/communications/new"
    end
  
    it "should map { :controller => 'communications', :action => 'show', :id => 1 } to /communications/1" do
      route_for(:controller => "communications", :action => "show", :id => 1).should == "/communications/1"
    end
  
    it "should map { :controller => 'communications', :action => 'edit', :id => 1 } to /communications/1/edit" do
      route_for(:controller => "communications", :action => "edit", :id => 1).should == "/communications/1/edit"
    end
  
    it "should map { :controller => 'communications', :action => 'update', :id => 1} to /communications/1" do
      route_for(:controller => "communications", :action => "update", :id => 1).should == "/communications/1"
    end
  
    it "should map { :controller => 'communications', :action => 'destroy', :id => 1} to /communications/1" do
      route_for(:controller => "communications", :action => "destroy", :id => 1).should == "/communications/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'communications', action => 'index' } from GET /communications" do
      params_from(:get, "/communications").should == {:controller => "communications", :action => "index"}
    end
  
    it "should generate params { :controller => 'communications', action => 'new' } from GET /communications/new" do
      params_from(:get, "/communications/new").should == {:controller => "communications", :action => "new"}
    end
  
    it "should generate params { :controller => 'communications', action => 'create' } from POST /communications" do
      params_from(:post, "/communications").should == {:controller => "communications", :action => "create"}
    end
  
    it "should generate params { :controller => 'communications', action => 'show', id => '1' } from GET /communications/1" do
      params_from(:get, "/communications/1").should == {:controller => "communications", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'communications', action => 'edit', id => '1' } from GET /communications/1;edit" do
      params_from(:get, "/communications/1/edit").should == {:controller => "communications", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'communications', action => 'update', id => '1' } from PUT /communications/1" do
      params_from(:put, "/communications/1").should == {:controller => "communications", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'communications', action => 'destroy', id => '1' } from DELETE /communications/1" do
      params_from(:delete, "/communications/1").should == {:controller => "communications", :action => "destroy", :id => "1"}
    end
  end
end