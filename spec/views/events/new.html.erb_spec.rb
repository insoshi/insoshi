require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/new.html.erb" do
  include EventsHelper
  
  before(:each) do
    @event = mock_model(Event)
    @event.stub!(:new_record?).and_return(true)
    @event.stub!(:person_id).and_return("1")
    @event.stub!(:instance_id).and_return("1")
    @event.stub!(:type).and_return("MyString")
    assigns[:event] = @event
  end

  it "should render new form" do
    render "/events/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", events_path) do
      with_tag("input#event_type[name=?]", "event[type]")
    end
  end
end


