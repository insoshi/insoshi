require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :description => "value for description",
      :person => people(:aaron),
      :start_time => Time.now,
      :end_time => Time.now,
      :reminder => false
    }
  end

  it "should create a new instance given valid attributes" do
    Event.create!(@valid_attributes)
  end

  describe "attendees association" do
    before(:each) do
      @event = events(:one)
      @person = people(:aaron)
    end
    
    it "should allow people to attend" do
      @event.attend(@person)                                   
      @event.attendees.should include(@person)
    end

    it 'should not allow people to attend twice' do
      @event.attend(@person).should_not be_nil
      @event.attend(@person).should be_nil
    end
                                       
    
  end

end
