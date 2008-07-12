require File.dirname(__FILE__) + '/../spec_helper'

# Return a list of system processes.
def processes
  process_cmd = case RUBY_PLATFORM
                when /djgpp|(cyg|ms|bcc)win|mingw/
                  'tasklist /v'
                when /solaris/
                  'ps -ef'
                else
                  'ps aux'
                end
  `#{process_cmd}`
end

# Return true if the search daemon is running.
def testing_search?
  processes.include?('searchd')
end

describe SearchesController do

  before(:each) do
    @back = "http://test.host/previous/page"
    request.env['HTTP_REFERER'] = @back
    login_as :quentin
    @preference = Preference.find(:first)
  end

  describe "Person searches" do

    it "should require login" do
      logout
      get :index, :q => "", :model => "Person"
      response.should redirect_to(login_url)
    end

    it "should return empty for a blank query" do
      get :index, :q => " ", :model => "Person"
      response.should be_success
      assigns(:results).should == [].paginate
    end
  
    it "should return empty for a 'wildcard' query" do
      get :index, :q => " ", :model => "Person"
      assigns(:results).should == [].paginate
    end

    it "should return Quentin for name query" do
      get :index, :q => "quentin", :model => "Person"
      assigns(:results).should == [people(:quentin)].paginate
    end
    
    it "should return Quentin for description query" do
      get :index, :q => "I'm Quentin", :model => "Person"
      assigns(:results).should == [people(:quentin)].paginate
    end
    
    describe "as a normal user" do
      
      it "should not return deactivated users" do
        people(:deactivated).should be_deactivated
        get :index, :q => "deactivated", :model => "Person"
        assigns(:results).should == [].paginate
      end
      
      it "should not return email unverified users" do
        @preference.email_verifications = true
        @preference.save!
        @preference.reload.email_verifications.should == true
        get :index, :q => "unverified", :model => "Person"
        assigns(:results).should == [].paginate
      end
      
    end
    
    describe "as an admin" do
      
      before(:each) do
        login_as :admin
      end

      it "should return deactivated users" do
        people(:deactivated).should be_deactivated
        get :index, :q => "deactivated", :model => "Person"
        assigns(:results).should == [people(:deactivated)].paginate
      end
      
      it "should return email unverified users" do
        @preference.email_verifications = true
        @preference.save!
        @preference.reload.email_verifications.should == true
        get :index, :q => "unverified", :model => "Person"
        assigns(:results).should == [people(:email_unverified)].paginate
      end

    end
    
  end

  # 
  # it "should return empty for a space-padded wildcard query" do
  #   Person.search(:q => " *  ").should == [].paginate
  # end
  # 
  # it "should not raise an error for a generic query" do
  #   lambda do
  #     Person.search(:q => "foobar")
  #   end.should_not raise_error
  # end
  # 
  # it "should return the Quentin for the search 'quentin'" do
  #   Person.search(:q => 'quentin').should == [people(:quentin)].paginate
  # end

  # it "should find people" do
  #   get :index, :q => "Quentin", :model => "Person"
  #   assigns(:results).should == [people(:quentin)].paginate
  # end
end if testing_search?