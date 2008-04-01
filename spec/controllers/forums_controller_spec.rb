require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController do
  integrate_views
  
  it "should show the topics if there is only one forum" 
  it "should show the forums if there are more than one forum" 
  it "should require login to view forums" 
  it "should only allow admins to create, edit, or destroy forums" 
end
