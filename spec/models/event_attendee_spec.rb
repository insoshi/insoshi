require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventAttendee do
  before(:each) do
    @person = people(:aaron)
    @event = events(:public)
    @event_attendee = EventAttendee.new(:event => @event,
                                        :person => @person)
  end
  
  it 'should be valid' do
    @event.should be_valid
  end

  describe "event_attendee activity associations" do
    before(:each) do
      @event_attendee.save!
      @activity = Activity.find_by_item_id(@event_attendee)
    end
    
    it "should have an activity" do
      @activity.should_not be_nil
    end
    
    it "should add an activity to the attendee" do
      @event_attendee.person.recent_activity.should contain(@activity)
    end
  end
end
