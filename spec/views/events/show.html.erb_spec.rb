require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/show.html.erb" do
  include EventsHelper
  
  before(:each) do
    @event = mock_model(Event)
    @event.stub!(:person_id).and_return("1")
    @event.stub!(:instance_id).and_return("1")
    @event.stub!(:type).and_return("MyString")

    assigns[:event] = @event
  end

  it "should render attributes in <p>" do
    render "/events/show.html.erb"
    response.should have_text(/MyString/)
  end
end

