require File.dirname(__FILE__) + '/../spec_helper'

describe ForumsController do
  describe "handling GET /forums" do

    before(:each) do
      @forum = mock_model(Forum)
      Forum.stub!(:find).and_return([@forum])
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
  
    it "should find all forums" do
      Forum.should_receive(:find).with(:all).and_return([@forum])
      do_get
    end
  
    it "should assign the found forums for the view" do
      do_get
      assigns[:forums].should == [@forum]
    end
  end

  describe "handling GET /forums.xml" do

    before(:each) do
      @forum = mock_model(Forum, :to_xml => "XML")
      Forum.stub!(:find).and_return(@forum)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all forums" do
      Forum.should_receive(:find).with(:all).and_return([@forum])
      do_get
    end
  
    it "should render the found forums as xml" do
      @forum.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forums/1" do

    before(:each) do
      @forum = mock_model(Forum)
      Forum.stub!(:find).and_return(@forum)
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
  
    it "should find the forum requested" do
      Forum.should_receive(:find).with("1").and_return(@forum)
      do_get
    end
  
    it "should assign the found forum for the view" do
      do_get
      assigns[:forum].should equal(@forum)
    end
  end

  describe "handling GET /forums/1.xml" do

    before(:each) do
      @forum = mock_model(Forum, :to_xml => "XML")
      Forum.stub!(:find).and_return(@forum)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the forum requested" do
      Forum.should_receive(:find).with("1").and_return(@forum)
      do_get
    end
  
    it "should render the found forum as xml" do
      @forum.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /forums/new" do

    before(:each) do
      @forum = mock_model(Forum)
      Forum.stub!(:new).and_return(@forum)
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
  
    it "should create an new forum" do
      Forum.should_receive(:new).and_return(@forum)
      do_get
    end
  
    it "should not save the new forum" do
      @forum.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new forum for the view" do
      do_get
      assigns[:forum].should equal(@forum)
    end
  end

  describe "handling GET /forums/1/edit" do

    before(:each) do
      @forum = mock_model(Forum)
      Forum.stub!(:find).and_return(@forum)
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
  
    it "should find the forum requested" do
      Forum.should_receive(:find).and_return(@forum)
      do_get
    end
  
    it "should assign the found Forum for the view" do
      do_get
      assigns[:forum].should equal(@forum)
    end
  end

  describe "handling POST /forums" do

    before(:each) do
      @forum = mock_model(Forum, :to_param => "1")
      Forum.stub!(:new).and_return(@forum)
    end
    
    describe "with successful save" do
  
      def do_post
        @forum.should_receive(:save).and_return(true)
        post :create, :forum => {}
      end
  
      it "should create a new forum" do
        Forum.should_receive(:new).with({}).and_return(@forum)
        do_post
      end

      it "should redirect to the new forum" do
        do_post
        response.should redirect_to(forum_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @forum.should_receive(:save).and_return(false)
        post :create, :forum => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /forums/1" do

    before(:each) do
      @forum = mock_model(Forum, :to_param => "1")
      Forum.stub!(:find).and_return(@forum)
    end
    
    describe "with successful update" do

      def do_put
        @forum.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the forum requested" do
        Forum.should_receive(:find).with("1").and_return(@forum)
        do_put
      end

      it "should update the found forum" do
        do_put
        assigns(:forum).should equal(@forum)
      end

      it "should assign the found forum for the view" do
        do_put
        assigns(:forum).should equal(@forum)
      end

      it "should redirect to the forum" do
        do_put
        response.should redirect_to(forum_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @forum.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /forums/1" do

    before(:each) do
      @forum = mock_model(Forum, :destroy => true)
      Forum.stub!(:find).and_return(@forum)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the forum requested" do
      Forum.should_receive(:find).with("1").and_return(@forum)
      do_delete
    end
  
    it "should call destroy on the found forum" do
      @forum.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the forums list" do
      do_delete
      response.should redirect_to(forums_url)
    end
  end
end