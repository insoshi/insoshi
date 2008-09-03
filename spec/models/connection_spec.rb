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
  
    it "should send an email when global/contact notifications are on" do
      # Both notifications are on by default.
      lambda do
        Connection.request(@person, @contact)
      end.should change(@emails, :length).by(1)
    end
    
    it "should not send an email when contact's notifications are off" do
      @contact.toggle!(:connection_notifications)
      @contact.connection_notifications.should == false
      lambda do
        Connection.request(@person, @contact)
      end.should_not change(@emails, :length)
    end
    
    it "should not send an email when global notifications are off" do
      @global_prefs.update_attributes(:email_notifications => false)
      lambda do
        Connection.request(@person, @contact)
      end.should_not change(@emails, :length)
    end
    
    describe "connect method" do
      it "should not send an email when contact's notifications are off" do
        @contact.toggle!(:connection_notifications)
        @contact.connection_notifications.should == false
        lambda do
          Connection.connect(@person, @contact)
        end.should_not change(@emails, :length)
      end
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
  
  
  it "should create a feed activity for a new connection" do
    connection = Connection.connect(@person, @contact)
    activity = Activity.find_by_item_id(connection)
    activity.should_not be_nil
    activity.person.should_not be_nil
  end
  
  it "should not create an activity for a connection with the first admin" do
    connection = Connection.connect(@person, Person.find_first_admin)
    Activity.find_by_item_id(connection).should be_nil
  end
  
  def status(person, conn)
    Connection.conn(person, conn).status
  end
end
