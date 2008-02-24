require File.dirname(__FILE__) + '/../spec_helper'

describe ConnectionsController do
  describe "handling GET /connections" do

    before(:each) do
      @connection = mock_model(Connection)
      Connection.stub!(:find).and_return([@connection])
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
  
    it "should find all connections" do
      Connection.should_receive(:find).with(:all).and_return([@connection])
      do_get
    end
  
    it "should assign the found connections for the view" do
      do_get
      assigns[:connections].should == [@connection]
    end
  end

  describe "handling GET /connections.xml" do

    before(:each) do
      @connection = mock_model(Connection, :to_xml => "XML")
      Connection.stub!(:find).and_return(@connection)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all connections" do
      Connection.should_receive(:find).with(:all).and_return([@connection])
      do_get
    end
  
    it "should render the found connections as xml" do
      @connection.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /connections/1" do

    before(:each) do
      @connection = mock_model(Connection)
      Connection.stub!(:find).and_return(@connection)
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
  
    it "should find the connection requested" do
      Connection.should_receive(:find).with("1").and_return(@connection)
      do_get
    end
  
    it "should assign the found connection for the view" do
      do_get
      assigns[:connection].should equal(@connection)
    end
  end

  describe "handling GET /connections/1.xml" do

    before(:each) do
      @connection = mock_model(Connection, :to_xml => "XML")
      Connection.stub!(:find).and_return(@connection)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the connection requested" do
      Connection.should_receive(:find).with("1").and_return(@connection)
      do_get
    end
  
    it "should render the found connection as xml" do
      @connection.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /connections/new" do

    before(:each) do
      @connection = mock_model(Connection)
      Connection.stub!(:new).and_return(@connection)
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
  
    it "should create an new connection" do
      Connection.should_receive(:new).and_return(@connection)
      do_get
    end
  
    it "should not save the new connection" do
      @connection.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new connection for the view" do
      do_get
      assigns[:connection].should equal(@connection)
    end
  end

  describe "handling GET /connections/1/edit" do

    before(:each) do
      @connection = mock_model(Connection)
      Connection.stub!(:find).and_return(@connection)
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
  
    it "should find the connection requested" do
      Connection.should_receive(:find).and_return(@connection)
      do_get
    end
  
    it "should assign the found Connection for the view" do
      do_get
      assigns[:connection].should equal(@connection)
    end
  end

  describe "handling POST /connections" do

    before(:each) do
      @connection = mock_model(Connection, :to_param => "1")
      Connection.stub!(:new).and_return(@connection)
    end
    
    describe "with successful save" do
  
      def do_post
        @connection.should_receive(:save).and_return(true)
        post :create, :connection => {}
      end
  
      it "should create a new connection" do
        Connection.should_receive(:new).with({}).and_return(@connection)
        do_post
      end

      it "should redirect to the new connection" do
        do_post
        response.should redirect_to(connection_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @connection.should_receive(:save).and_return(false)
        post :create, :connection => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /connections/1" do

    before(:each) do
      @connection = mock_model(Connection, :to_param => "1")
      Connection.stub!(:find).and_return(@connection)
    end
    
    describe "with successful update" do

      def do_put
        @connection.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the connection requested" do
        Connection.should_receive(:find).with("1").and_return(@connection)
        do_put
      end

      it "should update the found connection" do
        do_put
        assigns(:connection).should equal(@connection)
      end

      it "should assign the found connection for the view" do
        do_put
        assigns(:connection).should equal(@connection)
      end

      it "should redirect to the connection" do
        do_put
        response.should redirect_to(connection_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @connection.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /connections/1" do

    before(:each) do
      @connection = mock_model(Connection, :destroy => true)
      Connection.stub!(:find).and_return(@connection)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the connection requested" do
      Connection.should_receive(:find).with("1").and_return(@connection)
      do_delete
    end
  
    it "should call destroy on the found connection" do
      @connection.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the connections list" do
      do_delete
      response.should redirect_to(connections_url)
    end
  end
end