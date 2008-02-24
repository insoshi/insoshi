require File.dirname(__FILE__) + '/../spec_helper'

describe Connection do
  
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear    

    @person = people(:quentin)
    @connection = people(:aaron)
  end

  it "should create a request" do
    Connection.request(@person, @connection)
    status(@person, @connection).should == 'pending'
    status(@connection, @person).should == 'requested'
  end
  
  it "should send a request notification" do
    lambda do
      Connection.request(@person, @connection)
    end.should change(@emails, :length).by(1)
  end
    
  it "should accept a request" do
    Connection.request(@person, @connection)
    Connection.accept(@person,  @connection)
    status(@person, @connection).should == 'accepted'
    status(@connection, @person).should == 'accepted'    
  end
  
  it "should break up a connection" do
    Connection.request(@person, @connection)
    Connection.breakup(@person, @connection)
    Connection.exists?(@person, @connection).should be_false
  end
  
  def status(person, conn)
    Connection.find_by_person_id_and_contact_id(person, conn).status
  end
end
