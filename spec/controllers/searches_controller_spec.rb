require File.dirname(__FILE__) + '/../spec_helper'

# Return a list of system processes.
def processes
  process_cmd = case RUBY_PLATFORM
                when /djgpp|(cyg|ms|bcc)win|mingw/ then 'tasklist /v'
                when /solaris/                     then 'ps -ef'
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
    login_as :quentin
    @preference = Preference.find(:first)
  end

  describe "Person searches" do
    integrate_views

    it "should require login" do
      logout
      get :index, :q => "", :model => "Person"
      response.should redirect_to(login_url)
    end
    
    it "should redirect for an invalid model" do
      get :index, :q => "foo", :model => "AllPerson"
      response.should redirect_to(home_url)
    end

    it "should return empty for a blank query" do
      get :index, :q => " ", :model => "Person"
      response.should be_success
      assigns(:results).should == [].paginate
    end
    
    it "should return empty for a nil query" do
      get :index, :q => nil, :model => "Person"
      response.should be_redirect
      response.should redirect_to(home_url)
    end
  
    it "should return empty for a 'wildcard' query" do
      get :index, :q => "*", :model => "Person"
      assigns(:results).should == [].paginate
    end

    it "should search by name" do
      get :index, :q => "quentin", :model => "Person"
      assigns(:results).should == [people(:quentin)].paginate
    end
    
    it "should search by description" do
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
      integrate_views
      
      before(:each) do
        login_as :admin
      end

      it "should return deactivated users" do
        deactivated_person = people(:deactivated)
        deactivated_person.should be_deactivated
        get :index, :q => "deactivated", :model => "Person"
        assigns(:results).should contain(deactivated_person)
      end
      
      it "should return email unverified users" do
        @preference.email_verifications = true
        @preference.save!
        @preference.reload.email_verifications.should == true
        get :index, :q => "unverified", :model => "Person"
        assigns(:results).should contain(people(:email_unverified))
      end

    end
  end
  
  describe "Message searches" do
    
    before(:each) do
      @message = communications(:sent_to_quentin)
    end

    it "should search by subject" do
      get :index, :q => @message.subject, :model => "Message"
      assigns(:results).should contain(@message)
    end
    
    it "should search by content" do
      get :index, :q => @message.content, :model => "Message"
      assigns(:results).should contain(@message)      
    end
    
    it "should find only messages sent to logged-in user" do
      invalid_message = communications(:sent_to_aaron)
      get :index, :q => invalid_message.subject, :model => "Message"
      assigns(:results).should_not contain(invalid_message)
    end
    
    it "should not find trashed messages" do
      trashed_message = communications(:sent_to_quentin_from_kelly_and_trashed)
      get :index, :q => trashed_message.subject, :model => "Message"
      assigns(:results).should_not contain(trashed_message)      
    end
  end
  
  describe "Forum post searches" do
    integrate_views
    
    before(:each) do
      @post = posts(:forum)
    end
        
    it "should search by post body" do
      get :index, :q => @post.body, :model => "ForumPost"
      assigns(:results).should contain(@post)
    end
    
    it "should not raise errors due to finding blog posts" do
      # With STI, it's easy to include blog posts by accident.
      # When Ultrasphinx tries to use ForumPost on a blog post id,
      # it raises an ActiveRecord::RecordNotFound error.
      lambda do
        get :index, :q => posts(:blog_post).body, :model => "ForumPost"
      end.should_not raise_error(ActiveRecord::RecordNotFound)
    end
        
    it "should search by topic name" do
      get :index, :q => @post.topic.name, :model => "ForumPost"
      assigns(:results).should contain(@post)
    end
    
    it "should render with a post div" do
      get :index, :q => @post.body, :model => "ForumPost"
      response.should have_tag("div[class='forum']")
    end
    
    it "should render with a topic link" do
      topic = @post.topic
      get :index, :q => topic.name, :model => "ForumPost"
      url = forum_topic_path(topic.forum, topic, :anchor => "post_#{@post.id}")
      response.should have_tag("a[href=?]", url)
    end
  end
  
  describe "error handling" do
    it "should catch Ultrasphinx::UsageError exceptions" do
      invalid_query = "foo@bar"
      get :index, :q => invalid_query, :model => "Person"
      response.should be_redirect
      response.should redirect_to(searches_url(:q => "", :model => "Person"))
    end
  end
  
end if testing_search?