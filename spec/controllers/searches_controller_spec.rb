require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesController do
  
  before(:each) do
    @back = "http://test.host/previous/page"
    request.env['HTTP_REFERER'] = @back
  end

  
  it "should return empty for a blank query" do
    get :index, :q => " ", :model => "Person"
    response.should be_redirect
    response.should redirect_to(@back)
  end
  # 
  # it "should return empty for a wildcard query" do
  #   Person.search(:q => "*").should == [].paginate
  # end
  # 
  # it "should return empty for a space-padded wildcard query" do
  #   Person.search(:q => " *  ").should == [].paginate
  # end
  # 
  # it "should not raise an error for a generic query" do
  #   lambda do
  #     Person.search(:q => "foobar")
  #   end.should_not raise_error
  # end
  # 
  # it "should return the Quentin for the search 'quentin'" do
  #   Person.search(:q => 'quentin').should == [people(:quentin)].paginate
  # end
  
  # it "should find people" do
  #   get :index, :q => "Quentin", :model => "Person"
  #   assigns(:results).should == [people(:quentin)].paginate
  # end
end
