require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/index.html.erb" do
  include EventsHelper
  
  before(:each) do
    event_98 = mock_model(Event)
    event_98.should_receive(:person_id).and_return("1")
    event_98.should_receive(:instance_id).and_return("1")
    event_98.should_receive(:type).and_return("MyString")
    event_99 = mock_model(Event)
    event_99.should_receive(:person_id).and_return("1")
    event_99.should_receive(:instance_id).and_return("1")
    event_99.should_receive(:type).and_return("MyString")

    assigns[:events] = [event_98, event_99]
  end

  it "should render list of events" do
    render "/events/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
  end
end

