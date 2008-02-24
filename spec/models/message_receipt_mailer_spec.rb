require File.dirname(__FILE__) + '/../spec_helper'

describe MessageReceiptMailer do
  
  before(:each) do
    @message = people(:quentin).received_messages.first
    @reminder = MessageReceiptMailer.create_reminder(@message)
  end
  
  it "should have the right sender" do
    @reminder.from.first.should == "message-reminder@example.com"
  end
  
  it "should have the right recipient" do
    @reminder.to.first.should == @message.recipient.email
  end
end