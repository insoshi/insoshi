require File.dirname(__FILE__) + '/../spec_helper'

describe Connection do
  
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    @global_prefs = Preference.find(:first)
    
    @person = people(:quentin)
    @contact = people(:aaron)
  end

  describe "class methods" do

    it "should create a request" do
      Connection.request(@person, @contact)
      status(@person, @contact).should == Connection::PENDING
      status(@contact, @person).should == Connection::REQUESTED
    end
  
    it "should send a request notification when notifications are on" do
      @global_prefs.update_attributes(:email_notifications => true)
      lambda do
        Connection.request(@person, @contact)
      end.should change(@emails, :length).by(1)
    end
    
    it "should not send a request notification when notifications are off" do
      @global_prefs.update_attributes(:email_notifications => false)
      lambda do
        Connection.request(@person, @contact)
      end.should_not change(@emails, :length).by(1)      
    end
    
    it "should accept a request" do
      Connection.request(@person, @contact)
      Connection.accept(@person,  @contact)
      status(@person, @contact).should == Connection::ACCEPTED
      status(@contact, @person).should == Connection::ACCEPTED
    end
  
    it "should break up a connection" do
      Connection.request(@person, @contact)
      Connection.breakup(@person, @contact)
      Connection.exists?(@person, @contact).should be_false
    end
  end
  
  describe "instance methods" do
    
    before(:each) do
      Connection.request(@person, @contact)
      @connection = Connection.conn(@person, @contact)
    end
    
    it "should accept a request" do
      @connection.accept
    end
    
    it "should break up a connection" do
      @connection.breakup
      Connection.exists?(@person, @contact).should be_false
    end
  end
  
  describe "activity associations" do
    
    before(:each) do
      Connection.request(@person, @contact)
      @connection = Connection.conn(@person, @contact)
      @connection.accept
      @activity = Activity.find_by_item_id(@connection)
    end
  
    it "should have an activity" do
      @activity.should_not be_nil
      @activity.person.should_not be_nil
    end
  end
  
  def status(person, conn)
    Connection.conn(person, conn).status
  end
end
