require File.dirname(__FILE__) + '/../spec_helper'

describe PostsController do
  describe "handling GET /posts" do

    before(:each) do
      @post = mock_model(Post)
      Post.stub!(:find).and_return([@post])
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
  
    it "should find all posts" do
      Post.should_receive(:find).with(:all).and_return([@post])
      do_get
    end
  
    it "should assign the found posts for the view" do
      do_get
      assigns[:posts].should == [@post]
    end
  end

  describe "handling GET /posts.xml" do

    before(:each) do
      @post = mock_model(Post, :to_xml => "XML")
      Post.stub!(:find).and_return(@post)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all posts" do
      Post.should_receive(:find).with(:all).and_return([@post])
      do_get
    end
  
    it "should render the found posts as xml" do
      @post.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /posts/1" do

    before(:each) do
      @post = mock_model(Post)
      Post.stub!(:find).and_return(@post)
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
  
    it "should find the post requested" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_get
    end
  
    it "should assign the found post for the view" do
      do_get
      assigns[:post].should equal(@post)
    end
  end

  describe "handling GET /posts/1.xml" do

    before(:each) do
      @post = mock_model(Post, :to_xml => "XML")
      Post.stub!(:find).and_return(@post)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the post requested" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_get
    end
  
    it "should render the found post as xml" do
      @post.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /posts/new" do

    before(:each) do
      @post = mock_model(Post)
      Post.stub!(:new).and_return(@post)
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
  
    it "should create an new post" do
      Post.should_receive(:new).and_return(@post)
      do_get
    end
  
    it "should not save the new post" do
      @post.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new post for the view" do
      do_get
      assigns[:post].should equal(@post)
    end
  end

  describe "handling GET /posts/1/edit" do

    before(:each) do
      @post = mock_model(Post)
      Post.stub!(:find).and_return(@post)
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
  
    it "should find the post requested" do
      Post.should_receive(:find).and_return(@post)
      do_get
    end
  
    it "should assign the found Post for the view" do
      do_get
      assigns[:post].should equal(@post)
    end
  end

  describe "handling POST /posts" do

    before(:each) do
      @post = mock_model(Post, :to_param => "1")
      Post.stub!(:new).and_return(@post)
    end
    
    describe "with successful save" do
  
      def do_post
        @post.should_receive(:save).and_return(true)
        post :create, :post => {}
      end
  
      it "should create a new post" do
        Post.should_receive(:new).with({}).and_return(@post)
        do_post
      end

      it "should redirect to the new post" do
        do_post
        response.should redirect_to(post_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @post.should_receive(:save).and_return(false)
        post :create, :post => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /posts/1" do

    before(:each) do
      @post = mock_model(Post, :to_param => "1")
      Post.stub!(:find).and_return(@post)
    end
    
    describe "with successful update" do

      def do_put
        @post.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the post requested" do
        Post.should_receive(:find).with("1").and_return(@post)
        do_put
      end

      it "should update the found post" do
        do_put
        assigns(:post).should equal(@post)
      end

      it "should assign the found post for the view" do
        do_put
        assigns(:post).should equal(@post)
      end

      it "should redirect to the post" do
        do_put
        response.should redirect_to(post_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @post.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /posts/1" do

    before(:each) do
      @post = mock_model(Post, :destroy => true)
      Post.stub!(:find).and_return(@post)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the post requested" do
      Post.should_receive(:find).with("1").and_return(@post)
      do_delete
    end
  
    it "should call destroy on the found post" do
      @post.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the posts list" do
      do_delete
      response.should redirect_to(posts_url)
    end
  end
end