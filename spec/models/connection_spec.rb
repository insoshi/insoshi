require File.dirname(__FILE__) + '/../spec_helper'

describe Connection do
  
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear    

    @person = people(:quentin)
    @contact = people(:aaron)
  end

  describe "class methods" do

    it "should create a request" do
      Connection.request(@person, @contact)
      status(@person, @contact).should == Connection::PENDING
      status(@contact, @person).should == Connection::REQUESTED
    end
  
    it "should send a request notification" do
      lambda do
        Connection.request(@person, @contact)
      end.should change(@emails, :length).by(1)
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
  
  
  def status(person, conn)
    Connection.find_by_person_id_and_contact_id(person, conn).status
  end
end
