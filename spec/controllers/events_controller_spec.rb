require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

#TODO: Write tests about permissions
describe EventsController do
  
  before(:each) do
    @person = login_as(:aaron)
  end

  def mock_event(stubs={})
    stubs = {
      :save => true,
      :update_attributes => true,
      :destroy => true,
      :person => @person,
      :to_xml => '',
      :start_time => Time.now,
      :attendees => [],
      :only_contacts? => false
    }.merge(stubs)
    @mock_event ||= mock_model(Event, stubs)
  end

  describe "responding to GET /events" do

    it "should succeed" do
      Event.stub!(:paginate)
      get :index
      response.should be_success
    end

    it "should render the 'index' template" do
      Event.stub!(:paginate)
      get :index
      response.should render_template('index')
    end
  
    it "should find monthly events" do
      events = mock("Array of Events")
      Event.should_receive(:monthly_events).with(Time.now.to_date).and_return(events)
      events.should_receive(:person_events).with(@person).and_return(events)
      get :index
    end

    it "should find daily events" do
      events = mock("Array of Events")
      Event.should_receive(:daily_events).with(Time.now.to_date).and_return(events)
      events.should_receive(:person_events).with(@person).and_return(events)
      get :index, :day => Time.now.mday
    end

  
    it "should assign the found events for the view" do
      Event.should_receive(:find).and_return([mock_event])
      get :index
      assigns[:events].should == [mock_event]
    end

    it "should render the found events as xml" do
      request.env["HTTP_ACCEPT"] = "application/xml"
      events = mock("Array of Events")
      Event.should_receive(:monthly_events).and_return(events)
      events.should_receive(:person_events).and_return(events)
      events.should_receive(:to_xml).and_return("generated XML")
      get :index
      response.body.should == "generated XML"
    end

  end

  describe "responding to GET /events/1" do

    it "should succeed" do
      Event.stub!(:find).and_return(mock_event)      
      get :show, :id => "1"
      response.should be_success
      response.should render_template('show')
    end
  
    it "should render the 'show' template" do
      Event.stub!(:find).and_return(mock_event)
      get :show, :id => "1"
    end
  
    it "should find the requested event" do
      Event.should_receive(:find).with("37").and_return(mock_event)
      get :show, :id => "37"
    end
  
    it "should assign the found event for the view" do
      Event.should_receive(:find).and_return(mock_event)
      get :show, :id => "1"
      assigns[:event].should equal(mock_event)
    end

    it "should allow to see private events if contact" do
      contact = login_as(:quentin)
      Event.should_receive(:find).and_return(mock_event)
      mock_event.should_receive(:only_contacts?).and_return(true)
      Connection.connect(@person,contact)
      get :show, :id => "1"
      response.should be_success
    end

    it "should not allow to see private events if not contact" do
      login_as(:quentin)
      Event.should_receive(:find).and_return(mock_event)
      mock_event.should_receive(:only_contacts?).and_return(true)
      get :show, :id => "1"
      response.should be_redirect
    end
    
  end

  describe "responding to GET /events/1.xml" do

    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/xml"
    end
  
    it "should succeed" do
      Event.stub!(:find).and_return(mock_event)
      get :show, :id => "1"
      response.should be_success
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).with("37").and_return(mock_event)
      get :show, :id => "37"
    end
  
    it "should render the found event as xml" do
      Event.should_receive(:find).and_return(mock_event)
      mock_event.should_receive(:to_xml).and_return("generated XML")
      get :show, :id => "1"
      response.body.should == "generated XML"
    end

  end

  describe "responding to GET /events/new" do

    it "should succeed" do
      get :new
      response.should be_success
    end
  
    it "should render the 'new' template" do
      get :new
      response.should render_template('new')
    end
  
    it "should create a new event" do
      Event.should_receive(:new)
      get :new
    end
  
    it "should assign the new event for the view" do
      Event.should_receive(:new).and_return(mock_event)
      get :new
      assigns[:event].should equal(mock_event)
    end

  end

  describe "responding to GET /events/1/edit" do

    it "should succeed" do
      Event.stub!(:find).and_return(mock_event)
      get :edit, :id => "1"
      response.should be_success
    end
  
    it "should render the 'edit' template" do
      Event.stub!(:find).and_return(mock_event)
      get :edit, :id => "1"
      response.should render_template('edit')
    end
  
    it "should find the requested event" do
      Event.should_receive(:find).with("37").and_return(mock_event)
      get :edit, :id => "37"
    end
  
    it "should assign the found Event for the view" do
      Event.should_receive(:find).and_return(mock_event)
      get :edit, :id => "1"
      assigns[:event].should equal(mock_event)
    end

  end

  describe "responding to POST /events" do

    describe "with successful save" do
  
      it "should create a new event" do
        Event.should_receive(:new).with({'these' => 'params','person' => @person}).and_return(mock_event)
        post :create, :event => {:these => 'params'}
      end

      it "should assign the created event for the view" do
        Event.stub!(:new).and_return(mock_event)
        post :create, :event => {}
        assigns(:event).should equal(mock_event)
      end

      it "should redirect to the created event" do
        Event.stub!(:new).and_return(mock_event)
        post :create, :event => {}
        response.should redirect_to(event_url(mock_event))
      end
      
    end
    
    describe "with failed save" do

      it "should create a new event" do
        Event.should_receive(:new).with({'these' => 'params','person' => @person}).and_return(mock_event(:save => false))
        post :create, :event => {:these => 'params'}
      end

      it "should assign the invalid event for the view" do
        Event.stub!(:new).and_return(mock_event(:save => false))
        post :create, :event => {}
        assigns(:event).should equal(mock_event)
      end

      it "should re-render the 'new' template" do
        Event.stub!(:new).and_return(mock_event(:save => false))
        post :create, :event => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT /events/1" do

    describe "with successful update" do

      it "should find the requested event" do
        Event.should_receive(:find).with("37").and_return(mock_event)
        put :update, :id => "37"
      end

      it "should update the found event" do
        Event.stub!(:find).and_return(mock_event)
        mock_event.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "1", :event => {:these => 'params'}
      end

      it "should assign the found event for the view" do
        Event.stub!(:find).and_return(mock_event)
        put :update, :id => "1"
        assigns(:event).should equal(mock_event)
      end

      it "should redirect to the event" do
        Event.stub!(:find).and_return(mock_event)
        put :update, :id => "1"
        response.should redirect_to(event_url(mock_event))
      end

    end
    
    describe "with failed update" do

      it "should find the requested event" do
        Event.should_receive(:find).with("37").and_return(mock_event(:update_attributes => false))
        put :update, :id => "37"
      end

      it "should update the found event" do
        Event.stub!(:find).and_return(mock_event)
        mock_event.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "1", :event => {:these => 'params'}
      end

      it "should assign the found event for the view" do
        Event.stub!(:find).and_return(mock_event(:update_attributes => false))
        put :update, :id => "1"
        assigns(:event).should equal(mock_event)
      end

      it "should re-render the 'edit' template" do
        Event.stub!(:find).and_return(mock_event(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE /events/1" do

    it "should find the event requested" do
      Event.should_receive(:find).with("37").and_return(mock_event)
      delete :destroy, :id => "37"
    end
  
    it "should call destroy on the found event" do
      Event.stub!(:find).and_return(mock_event)
      mock_event.should_receive(:destroy)
      delete :destroy, :id => "1"
    end
  
    it "should redirect to the events list" do
      Event.stub!(:find).and_return(mock_event)
      delete :destroy, :id => "1"
      response.should redirect_to(events_url)
    end

  end

end
