require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  describe "route generation" do

    it "should map { :controller => 'topics', :action => 'index' } to /topics" do
      route_for(:controller => "topics", :action => "index").should == "/topics"
    end
  
    it "should map { :controller => 'topics', :action => 'new' } to /topics/new" do
      route_for(:controller => "topics", :action => "new").should == "/topics/new"
    end
  
    it "should map { :controller => 'topics', :action => 'show', :id => 1 } to /topics/1" do
      route_for(:controller => "topics", :action => "show", :id => 1).should == "/topics/1"
    end
  
    it "should map { :controller => 'topics', :action => 'edit', :id => 1 } to /topics/1/edit" do
      route_for(:controller => "topics", :action => "edit", :id => 1).should == "/topics/1/edit"
    end
  
    it "should map { :controller => 'topics', :action => 'update', :id => 1} to /topics/1" do
      route_for(:controller => "topics", :action => "update", :id => 1).should == "/topics/1"
    end
  
    it "should map { :controller => 'topics', :action => 'destroy', :id => 1} to /topics/1" do
      route_for(:controller => "topics", :action => "destroy", :id => 1).should == "/topics/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'topics', action => 'index' } from GET /topics" do
      params_from(:get, "/topics").should == {:controller => "topics", :action => "index"}
    end
  
    it "should generate params { :controller => 'topics', action => 'new' } from GET /topics/new" do
      params_from(:get, "/topics/new").should == {:controller => "topics", :action => "new"}
    end
  
    it "should generate params { :controller => 'topics', action => 'create' } from POST /topics" do
      params_from(:post, "/topics").should == {:controller => "topics", :action => "create"}
    end
  
    it "should generate params { :controller => 'topics', action => 'show', id => '1' } from GET /topics/1" do
      params_from(:get, "/topics/1").should == {:controller => "topics", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'topics', action => 'edit', id => '1' } from GET /topics/1;edit" do
      params_from(:get, "/topics/1/edit").should == {:controller => "topics", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'topics', action => 'update', id => '1' } from PUT /topics/1" do
      params_from(:put, "/topics/1").should == {:controller => "topics", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'topics', action => 'destroy', id => '1' } from DELETE /topics/1" do
      params_from(:delete, "/topics/1").should == {:controller => "topics", :action => "destroy", :id => "1"}
    end
  end
end