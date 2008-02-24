require File.dirname(__FILE__) + '/../../spec_helper'

describe "/connections/edit.html.erb" do
  include ConnectionsHelper
  
  before do
    @connection = mock_model(Connection)
    @connection.stub!(:person_id).and_return("1")
    @connection.stub!(:connection_id).and_return("1")
    @connection.stub!(:status).and_return("MyString")
    assigns[:connection] = @connection
  end

  it "should render edit form" do
    render "/connections/edit.html.erb"
    
    response.should have_tag("form[action=#{connection_path(@connection)}][method=post]") do
      with_tag('input#connection_status[name=?]', "connection[status]")
    end
  end
end


