require File.dirname(__FILE__) + '/../spec_helper'

describe EmailVerification do
  
  it "should be valid" do
    email_verifications(:one).should be_valid
  end
  
  it "should have an associated person" 
  
end