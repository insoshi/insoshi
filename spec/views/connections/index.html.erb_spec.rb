require File.dirname(__FILE__) + '/../../spec_helper'

describe "/connections/index.html.erb" do
  include ConnectionsHelper
  
  before(:each) do
    connection_98 = mock_model(Connection)
    connection_98.should_receive(:person_id).and_return("1")
    connection_98.should_receive(:connection_id).and_return("1")
    connection_98.should_receive(:status).and_return("MyString")
    connection_99 = mock_model(Connection)
    connection_99.should_receive(:person_id).and_return("1")
    connection_99.should_receive(:connection_id).and_return("1")
    connection_99.should_receive(:status).and_return("MyString")

    assigns[:connections] = [connection_98, connection_99]
  end

  it "should render list of connections" do
    render "/connections/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

