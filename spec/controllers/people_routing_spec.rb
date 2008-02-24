require File.dirname(__FILE__) + '/../spec_helper'

describe PeopleController do
  describe "route generation" do

    it "should map { :controller => 'people', :action => 'search' } to /people/search" do
      route_for(:controller => "people", :action => "search").should == "/people/search"
    end

  end

  describe "route recognition" do

    it "should generate params { :controller => 'people', action => 'search' } from GET /people/search" do
      params_from(:get, "/people/search").should == {:controller => "people", :action => "search"}
    end
  end
end