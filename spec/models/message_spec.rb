require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    @sender    = people(:quentin)
    @recipient = people(:aaron)
    @message   = new_message
  end
  
  it "should be valid" do
    @message.should be_valid
  end
  
  it "should have the right sender" do
    @message.sender.should == @sender
  end
  
  it "should have the right recipient" do
    @message.recipient.should == @recipient
  end
  
  it "should require content" do
    new_message(:content => "").should_not be_valid
  end
  
  it "should not be too long" do
    too_long_content = "a" * (Message::MAX_CONTENT_LENGTH + 1)
    new_message(:content => too_long_content).should_not be_valid
  end

  it "should be able to trash messages" 
  
  it "should handle replies" 
  
  it "should mark messages as read" 



  private

    def new_message(options = { :sender => @sender, :recipient => @recipient })   
      Message.new({ :content   => "Lorem ipsum" }.merge(options))
    end
  
    # TODO: remove this (?)
    def create_message(sender = @sender, recipient = @recipient)   
      Message.create(:content   => "Lorem ipsum",
                     :sender    => sender,
                     :recipient => recipient)
    end
end