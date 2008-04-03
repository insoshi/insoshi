require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesController do
  it "should find people" do
    get :index, :q => "Quentin", :model => "Person"
    assigns(:results).should == [people(:quentin)].paginate
  end
end if SEARCH_IN_TESTS
