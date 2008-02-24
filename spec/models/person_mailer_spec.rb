require File.dirname(__FILE__) + '/../spec_helper'

describe PersonMailer do
  
  before(:each) do
    @person = people(:quentin)
    @reminder = PersonMailer.create_password_reminder(@person)    
  end
  
  it "should have the right sender" do
    @reminder.from.first.should == "password-reminder@example.com"
  end
  
  it "should have the right recipient" do
    @reminder.to.first.should == @person.email
  end
  
  it "should have the unencrypted password in the body" do
    @reminder.body.should =~ /#{@person.unencrypted_password}/
  end
end