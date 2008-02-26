require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  describe "handling GET /comments" do

    before(:each) do
      @comment = mock_model(Comment)
      Comment.stub!(:find).and_return([@comment])
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
  
    it "should find all comments" do
      Comment.should_receive(:find).with(:all).and_return([@comment])
      do_get
    end
  
    it "should assign the found comments for the view" do
      do_get
      assigns[:comments].should == [@comment]
    end
  end

  describe "handling GET /comments.xml" do

    before(:each) do
      @comment = mock_model(Comment, :to_xml => "XML")
      Comment.stub!(:find).and_return(@comment)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all comments" do
      Comment.should_receive(:find).with(:all).and_return([@comment])
      do_get
    end
  
    it "should render the found comments as xml" do
      @comment.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /comments/1" do

    before(:each) do
      @comment = mock_model(Comment)
      Comment.stub!(:find).and_return(@comment)
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
  
    it "should find the comment requested" do
      Comment.should_receive(:find).with("1").and_return(@comment)
      do_get
    end
  
    it "should assign the found comment for the view" do
      do_get
      assigns[:comment].should equal(@comment)
    end
  end

  describe "handling GET /comments/1.xml" do

    before(:each) do
      @comment = mock_model(Comment, :to_xml => "XML")
      Comment.stub!(:find).and_return(@comment)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the comment requested" do
      Comment.should_receive(:find).with("1").and_return(@comment)
      do_get
    end
  
    it "should render the found comment as xml" do
      @comment.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /comments/new" do

    before(:each) do
      @comment = mock_model(Comment)
      Comment.stub!(:new).and_return(@comment)
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
  
    it "should create an new comment" do
      Comment.should_receive(:new).and_return(@comment)
      do_get
    end
  
    it "should not save the new comment" do
      @comment.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new comment for the view" do
      do_get
      assigns[:comment].should equal(@comment)
    end
  end

  describe "handling GET /comments/1/edit" do

    before(:each) do
      @comment = mock_model(Comment)
      Comment.stub!(:find).and_return(@comment)
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
  
    it "should find the comment requested" do
      Comment.should_receive(:find).and_return(@comment)
      do_get
    end
  
    it "should assign the found Comment for the view" do
      do_get
      assigns[:comment].should equal(@comment)
    end
  end

  describe "handling POST /comments" do

    before(:each) do
      @comment = mock_model(Comment, :to_param => "1")
      Comment.stub!(:new).and_return(@comment)
    end
    
    describe "with successful save" do
  
      def do_post
        @comment.should_receive(:save).and_return(true)
        post :create, :comment => {}
      end
  
      it "should create a new comment" do
        Comment.should_receive(:new).with({}).and_return(@comment)
        do_post
      end

      it "should redirect to the new comment" do
        do_post
        response.should redirect_to(comment_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @comment.should_receive(:save).and_return(false)
        post :create, :comment => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /comments/1" do

    before(:each) do
      @comment = mock_model(Comment, :to_param => "1")
      Comment.stub!(:find).and_return(@comment)
    end
    
    describe "with successful update" do

      def do_put
        @comment.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the comment requested" do
        Comment.should_receive(:find).with("1").and_return(@comment)
        do_put
      end

      it "should update the found comment" do
        do_put
        assigns(:comment).should equal(@comment)
      end

      it "should assign the found comment for the view" do
        do_put
        assigns(:comment).should equal(@comment)
      end

      it "should redirect to the comment" do
        do_put
        response.should redirect_to(comment_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @comment.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /comments/1" do

    before(:each) do
      @comment = mock_model(Comment, :destroy => true)
      Comment.stub!(:find).and_return(@comment)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the comment requested" do
      Comment.should_receive(:find).with("1").and_return(@comment)
      do_delete
    end
  
    it "should call destroy on the found comment" do
      @comment.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the comments list" do
      do_delete
      response.should redirect_to(comments_url)
    end
  end
end