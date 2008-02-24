require File.dirname(__FILE__) + '/../../spec_helper'

describe "/connections/show.html.erb" do
  include ConnectionsHelper
  
  before(:each) do
    @connection = mock_model(Connection)
    @connection.stub!(:person_id).and_return("1")
    @connection.stub!(:connection_id).and_return("1")
    @connection.stub!(:status).and_return("MyString")

    assigns[:connection] = @connection
  end

  it "should render attributes in <p>" do
    render "/connections/show.html.erb"
    response.should have_text(/MyString/)
  end
end

