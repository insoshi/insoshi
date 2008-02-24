require File.dirname(__FILE__) + '/../../spec_helper'

describe "/connections/new.html.erb" do
  include ConnectionsHelper
  
  before(:each) do
    @connection = mock_model(Connection)
    @connection.stub!(:new_record?).and_return(true)
    @connection.stub!(:person_id).and_return("1")
    @connection.stub!(:connection_id).and_return("1")
    @connection.stub!(:status).and_return("MyString")
    assigns[:connection] = @connection
  end

  it "should render new form" do
    render "/connections/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", connections_path) do
      with_tag("input#connection_status[name=?]", "connection[status]")
    end
  end
end


