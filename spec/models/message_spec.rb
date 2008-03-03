require File.dirname(__FILE__) + '/../spec_helper'

describe Message do
  
  before(:each) do
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
  
  it "should require a subject" do
    new_message(:subject => "").should_not be_valid
  end
  
  it "should require content" do
    new_message(:content => "").should_not be_valid
  end
  
  it "should not be too long" do
    too_long_content = "a" * (Message::MAX_CONTENT_LENGTH + 1)
    new_message(:content => too_long_content).should_not be_valid
  end

  it "should be able to trash messages as sender" do
    @message.trash(@message.sender)
    @message.should be_trashed(@message.sender)
    @message.should_not be_trashed(@message.recipient)
  end
  
  it "should be able to trash message as recipient" do
    @message.trash(@message.recipient)
    @message.should be_trashed(@message.recipient) 
    @message.should_not be_trashed(@message.sender)
  end
  
  it "should description not be able to trash as another user" do
    kelly = people(:kelly)
    kelly.should_not == @message.sender
    kelly.should_not == @message.recipient
    lambda { @message.trash(kelly) }.should raise_error(ArgumentError)
  end
  
  it "should untrash messages" do
    @message.trash(@message.sender)
    @message.should be_trashed(@message.sender)
    @message.untrash(@message.sender)
    @message.should_not be_trashed(@message.sender)
  end
  
  it "should handle replies" do
    @message.save!
    @reply = create_message(:sender    => @message.recipient,
                            :recipient => @message.sender,
                            :parent_id => @message)
    @reply.should be_reply
    @reply.parent.should be_replied_to
  end

  it "should not allow anyone but recipient to reply" do
    @message.save!
    @next_message = create_message(:sender    => people(:kelly),
                                   :recipient => @message.sender,
                                   :parent_id => @message)
    @next_message.should_not be_reply
    @next_message.parent.should_not be_replied_to
  end
  
  it "should mark messages as read" do
    @message.mark_as_read
    @message.should be_read
  end

  private

    def new_message(options = { :sender => @sender, :recipient => @recipient })   
      Message.new({ :subject => "The subject",
                    :content => "Lorem ipsum" }.merge(options))
    end
  
    def create_message(options = { :sender => @sender,
                                   :recipient => @recipient })   
      Message.create({ :subject => "The subject",
                       :content => "Lorem ipsum" }.merge(options))
    end
end