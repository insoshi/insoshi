require File.dirname(__FILE__) + '/../spec_helper'

describe Preference do
  before(:each) do
    @preferences = Preference.new
  end

  it "should require email settings for email notifications" do
    @preferences.email_notifications = true
    @preferences.save.should be_false
    @preferences.errors_on(:email_domain).should_not be_empty
    @preferences.errors_on(:smtp_server).should_not be_empty
  end
  
  it "should have a working email_verifications boolean" do
    @preferences.should respond_to(:email_verifications?) 
  end
  
  describe "booleans from fixtures" do
    
    before(:each) do
      @preferences = preferences(:one)
    end
    
    it "should have true email notifications" do
      @preferences.email_notifications?.should be_true
    end
    
    it "should have false email verifications" do
      @preferences.email_verifications?.should be_false
    end
  end
  
end
