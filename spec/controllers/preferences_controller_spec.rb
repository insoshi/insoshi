require File.dirname(__FILE__) + '/../spec_helper'

describe PreferencesController do
  describe "handling GET /preferences" do

    before(:each) do
      @preference = mock_model(Preference)
      Preference.stub!(:find).and_return([@preference])
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
  
    it "should find all preferences" do
      Preference.should_receive(:find).with(:all).and_return([@preference])
      do_get
    end
  
    it "should assign the found preferences for the view" do
      do_get
      assigns[:preferences].should == [@preference]
    end
  end

  describe "handling GET /preferences.xml" do

    before(:each) do
      @preference = mock_model(Preference, :to_xml => "XML")
      Preference.stub!(:find).and_return(@preference)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all preferences" do
      Preference.should_receive(:find).with(:all).and_return([@preference])
      do_get
    end
  
    it "should render the found preferences as xml" do
      @preference.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /preferences/1" do

    before(:each) do
      @preference = mock_model(Preference)
      Preference.stub!(:find).and_return(@preference)
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
  
    it "should find the preference requested" do
      Preference.should_receive(:find).with("1").and_return(@preference)
      do_get
    end
  
    it "should assign the found preference for the view" do
      do_get
      assigns[:preference].should equal(@preference)
    end
  end

  describe "handling GET /preferences/1.xml" do

    before(:each) do
      @preference = mock_model(Preference, :to_xml => "XML")
      Preference.stub!(:find).and_return(@preference)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the preference requested" do
      Preference.should_receive(:find).with("1").and_return(@preference)
      do_get
    end
  
    it "should render the found preference as xml" do
      @preference.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /preferences/new" do

    before(:each) do
      @preference = mock_model(Preference)
      Preference.stub!(:new).and_return(@preference)
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
  
    it "should create an new preference" do
      Preference.should_receive(:new).and_return(@preference)
      do_get
    end
  
    it "should not save the new preference" do
      @preference.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new preference for the view" do
      do_get
      assigns[:preference].should equal(@preference)
    end
  end

  describe "handling GET /preferences/1/edit" do

    before(:each) do
      @preference = mock_model(Preference)
      Preference.stub!(:find).and_return(@preference)
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
  
    it "should find the preference requested" do
      Preference.should_receive(:find).and_return(@preference)
      do_get
    end
  
    it "should assign the found Preference for the view" do
      do_get
      assigns[:preference].should equal(@preference)
    end
  end

  describe "handling POST /preferences" do

    before(:each) do
      @preference = mock_model(Preference, :to_param => "1")
      Preference.stub!(:new).and_return(@preference)
    end
    
    describe "with successful save" do
  
      def do_post
        @preference.should_receive(:save).and_return(true)
        post :create, :preference => {}
      end
  
      it "should create a new preference" do
        Preference.should_receive(:new).with({}).and_return(@preference)
        do_post
      end

      it "should redirect to the new preference" do
        do_post
        response.should redirect_to(preference_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @preference.should_receive(:save).and_return(false)
        post :create, :preference => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /preferences/1" do

    before(:each) do
      @preference = mock_model(Preference, :to_param => "1")
      Preference.stub!(:find).and_return(@preference)
    end
    
    describe "with successful update" do

      def do_put
        @preference.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the preference requested" do
        Preference.should_receive(:find).with("1").and_return(@preference)
        do_put
      end

      it "should update the found preference" do
        do_put
        assigns(:preference).should equal(@preference)
      end

      it "should assign the found preference for the view" do
        do_put
        assigns(:preference).should equal(@preference)
      end

      it "should redirect to the preference" do
        do_put
        response.should redirect_to(preference_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @preference.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /preferences/1" do

    before(:each) do
      @preference = mock_model(Preference, :destroy => true)
      Preference.stub!(:find).and_return(@preference)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the preference requested" do
      Preference.should_receive(:find).with("1").and_return(@preference)
      do_delete
    end
  
    it "should call destroy on the found preference" do
      @preference.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the preferences list" do
      do_delete
      response.should redirect_to(preferences_url)
    end
  end
end