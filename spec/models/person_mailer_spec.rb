require File.dirname(__FILE__) + '/../spec_helper'

describe PersonMailer do
  
  describe "password reminder" do
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
  
  describe "message notification" do
    before(:each) do
      @message = people(:quentin).received_messages.first
      @reminder = PersonMailer.create_message_notification(@message)
    end
  
    it "should have the right sender" do
      @reminder.from.first.should == "message@example.com"
    end
  
    it "should have the right recipient" do
      @reminder.to.first.should == @message.recipient.email
    end
  end
end