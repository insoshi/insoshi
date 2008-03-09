require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/edit.html.erb" do
  include EventsHelper
  
  before do
    @event = mock_model(Event)
    @event.stub!(:person_id).and_return("1")
    @event.stub!(:instance_id).and_return("1")
    @event.stub!(:type).and_return("MyString")
    assigns[:event] = @event
  end

  it "should render edit form" do
    render "/events/edit.html.erb"
    
    response.should have_tag("form[action=#{event_path(@event)}][method=post]") do
      with_tag('input#event_type[name=?]', "event[type]")
    end
  end
end


