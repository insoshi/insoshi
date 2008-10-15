require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController do
  describe "route generation" do

    it "should map { :controller => 'events', :action => 'index' } to /events" do
      route_for(:controller => "events", :action => "index").should == "/events"
    end
  
    it "should map { :controller => 'events', :action => 'new' } to /events/new" do
      route_for(:controller => "events", :action => "new").should == "/events/new"
    end
  
    it "should map { :controller => 'events', :action => 'show', :id => 1 } to /events/1" do
      route_for(:controller => "events", :action => "show", :id => 1).should == "/events/1"
    end
  
    it "should map { :controller => 'events', :action => 'edit', :id => 1 } to /events/1/edit" do
      route_for(:controller => "events", :action => "edit", :id => 1).should == "/events/1/edit"
    end
  
    it "should map { :controller => 'events', :action => 'update', :id => 1} to /events/1" do
      route_for(:controller => "events", :action => "update", :id => 1).should == "/events/1"
    end
  
    it "should map { :controller => 'events', :action => 'destroy', :id => 1} to /events/1" do
      route_for(:controller => "events", :action => "destroy", :id => 1).should == "/events/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'events', action => 'index' } from GET /events" do
      params_from(:get, "/events").should == {:controller => "events", :action => "index"}
    end
  
    it "should generate params { :controller => 'events', action => 'new' } from GET /events/new" do
      params_from(:get, "/events/new").should == {:controller => "events", :action => "new"}
    end
  
    it "should generate params { :controller => 'events', action => 'create' } from POST /events" do
      params_from(:post, "/events").should == {:controller => "events", :action => "create"}
    end
  
    it "should generate params { :controller => 'events', action => 'show', id => '1' } from GET /events/1" do
      params_from(:get, "/events/1").should == {:controller => "events", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'events', action => 'edit', id => '1' } from GET /events/1;edit" do
      params_from(:get, "/events/1/edit").should == {:controller => "events", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'events', action => 'update', id => '1' } from PUT /events/1" do
      params_from(:put, "/events/1").should == {:controller => "events", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'events', action => 'destroy', id => '1' } from DELETE /events/1" do
      params_from(:delete, "/events/1").should == {:controller => "events", :action => "destroy", :id => "1"}
    end
  end
end
