require File.dirname(__FILE__) + '/../spec_helper'

describe TopicsController do
  describe "handling GET /topics" do

    before(:each) do
      @topic = mock_model(Topic)
      Topic.stub!(:find).and_return([@topic])
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
  
    it "should find all topics" do
      Topic.should_receive(:find).with(:all).and_return([@topic])
      do_get
    end
  
    it "should assign the found topics for the view" do
      do_get
      assigns[:topics].should == [@topic]
    end
  end

  describe "handling GET /topics.xml" do

    before(:each) do
      @topic = mock_model(Topic, :to_xml => "XML")
      Topic.stub!(:find).and_return(@topic)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all topics" do
      Topic.should_receive(:find).with(:all).and_return([@topic])
      do_get
    end
  
    it "should render the found topics as xml" do
      @topic.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /topics/1" do

    before(:each) do
      @topic = mock_model(Topic)
      Topic.stub!(:find).and_return(@topic)
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
  
    it "should find the topic requested" do
      Topic.should_receive(:find).with("1").and_return(@topic)
      do_get
    end
  
    it "should assign the found topic for the view" do
      do_get
      assigns[:topic].should equal(@topic)
    end
  end

  describe "handling GET /topics/1.xml" do

    before(:each) do
      @topic = mock_model(Topic, :to_xml => "XML")
      Topic.stub!(:find).and_return(@topic)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the topic requested" do
      Topic.should_receive(:find).with("1").and_return(@topic)
      do_get
    end
  
    it "should render the found topic as xml" do
      @topic.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /topics/new" do

    before(:each) do
      @topic = mock_model(Topic)
      Topic.stub!(:new).and_return(@topic)
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
  
    it "should create an new topic" do
      Topic.should_receive(:new).and_return(@topic)
      do_get
    end
  
    it "should not save the new topic" do
      @topic.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new topic for the view" do
      do_get
      assigns[:topic].should equal(@topic)
    end
  end

  describe "handling GET /topics/1/edit" do

    before(:each) do
      @topic = mock_model(Topic)
      Topic.stub!(:find).and_return(@topic)
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
  
    it "should find the topic requested" do
      Topic.should_receive(:find).and_return(@topic)
      do_get
    end
  
    it "should assign the found Topic for the view" do
      do_get
      assigns[:topic].should equal(@topic)
    end
  end

  describe "handling POST /topics" do

    before(:each) do
      @topic = mock_model(Topic, :to_param => "1")
      Topic.stub!(:new).and_return(@topic)
    end
    
    describe "with successful save" do
  
      def do_post
        @topic.should_receive(:save).and_return(true)
        post :create, :topic => {}
      end
  
      it "should create a new topic" do
        Topic.should_receive(:new).with({}).and_return(@topic)
        do_post
      end

      it "should redirect to the new topic" do
        do_post
        response.should redirect_to(topic_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @topic.should_receive(:save).and_return(false)
        post :create, :topic => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /topics/1" do

    before(:each) do
      @topic = mock_model(Topic, :to_param => "1")
      Topic.stub!(:find).and_return(@topic)
    end
    
    describe "with successful update" do

      def do_put
        @topic.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the topic requested" do
        Topic.should_receive(:find).with("1").and_return(@topic)
        do_put
      end

      it "should update the found topic" do
        do_put
        assigns(:topic).should equal(@topic)
      end

      it "should assign the found topic for the view" do
        do_put
        assigns(:topic).should equal(@topic)
      end

      it "should redirect to the topic" do
        do_put
        response.should redirect_to(topic_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @topic.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /topics/1" do

    before(:each) do
      @topic = mock_model(Topic, :destroy => true)
      Topic.stub!(:find).and_return(@topic)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the topic requested" do
      Topic.should_receive(:find).with("1").and_return(@topic)
      do_delete
    end
  
    it "should call destroy on the found topic" do
      @topic.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the topics list" do
      do_delete
      response.should redirect_to(topics_url)
    end
  end
end