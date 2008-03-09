require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController do
  describe "handling GET /events" do

    before(:each) do
      @event = mock_model(Event)
      Event.stub!(:find).and_return([@event])
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should find all events" do
      Event.should_receive(:find).with(:all).and_return([@event])
      do_get
    end
  
    it "should assign the found events for the view" do
      do_get
      assigns[:events].should == [@event]
    end
  end

  describe "handling GET /events.xml" do

    before(:each) do
      @event = mock_model(Event, :to_xml => "XML")
      Event.stub!(:find).and_return(@event)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all events" do
      Event.should_receive(:find).with(:all).and_return([@event])
      do_get
    end
  
    it "should render the found events as xml" do
      @event.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /events/1" do

    before(:each) do
      @event = mock_model(Event)
      Event.stub!(:find).and_return(@event)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).with("1").and_return(@event)
      do_get
    end
  
    it "should assign the found event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling GET /events/1.xml" do

    before(:each) do
      @event = mock_model(Event, :to_xml => "XML")
      Event.stub!(:find).and_return(@event)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).with("1").and_return(@event)
      do_get
    end
  
    it "should render the found event as xml" do
      @event.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /events/new" do

    before(:each) do
      @event = mock_model(Event)
      Event.stub!(:new).and_return(@event)
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render new template" do
      do_get
      response.should render_template('new')
    end
  
    it "should create an new event" do
      Event.should_receive(:new).and_return(@event)
      do_get
    end
  
    it "should not save the new event" do
      @event.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling GET /events/1/edit" do

    before(:each) do
      @event = mock_model(Event)
      Event.stub!(:find).and_return(@event)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the event requested" do
      Event.should_receive(:find).and_return(@event)
      do_get
    end
  
    it "should assign the found Event for the view" do
      do_get
      assigns[:event].should equal(@event)
    end
  end

  describe "handling POST /events" do

    before(:each) do
      @event = mock_model(Event, :to_param => "1")
      Event.stub!(:new).and_return(@event)
    end
    
    describe "with successful save" do
  
      def do_post
        @event.should_receive(:save).and_return(true)
        post :create, :event => {}
      end
  
      it "should create a new event" do
        Event.should_receive(:new).with({}).and_return(@event)
        do_post
      end

      it "should redirect to the new event" do
        do_post
        response.should redirect_to(event_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @event.should_receive(:save).and_return(false)
        post :create, :event => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /events/1" do

    before(:each) do
      @event = mock_model(Event, :to_param => "1")
      Event.stub!(:find).and_return(@event)
    end
    
    describe "with successful update" do

      def do_put
        @event.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the event requested" do
        Event.should_receive(:find).with("1").and_return(@event)
        do_put
      end

      it "should update the found event" do
        do_put
        assigns(:event).should equal(@event)
      end

      it "should assign the found event for the view" do
        do_put
        assigns(:event).should equal(@event)
      end

      it "should redirect to the event" do
        do_put
        response.should redirect_to(event_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @event.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /events/1" do

    before(:each) do
      @event = mock_model(Event, :destroy => true)
      Event.stub!(:find).and_return(@event)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the event requested" do
      Event.should_receive(:find).with("1").and_return(@event)
      do_delete
    end
  
    it "should call destroy on the found event" do
      @event.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the events list" do
      do_delete
      response.should redirect_to(events_url)
    end
  end
end