require File.dirname(__FILE__) + '/../spec_helper'

describe EmailVerification do
  
  before(:each) do
    @emails = ActionMailer::Base.deliveries
    @emails.clear    
    
    @ev = email_verifications(:one)
    @person = people(:quentin)
  end
  
  it "should be valid" do
    @ev.should be_valid
  end
  
  it "should have an associated person" do
    @ev.person.should == @person
  end
  
  it "should make a code for new verifications" do
    ev = EmailVerification.new
    ev.person = @person
    ev.save.should be_true
    ev.code.should_not be_blank
  end

  it "should allow creation through a person" do
    lambda do
      ev = @person.email_verifications.create!
      ev.person.should == @person
    end.should_not raise_error
  end
end