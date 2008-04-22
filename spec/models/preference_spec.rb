require File.dirname(__FILE__) + '/../spec_helper'

describe Preference do
  
  describe "validations" do
    before(:each) do
      @preferences = Preference.new
    end

    it "should require email settings for email notifications" do
      @preferences.email_notifications = true
      @preferences.save.should be_false
      @preferences.errors_on(:domain).should_not be_empty
      @preferences.errors_on(:smtp_server).should_not be_empty
    end

    it "should require email settings for email verifications" do
      @preferences.email_verifications = true
      @preferences.save.should be_false
      @preferences.errors_on(:domain).should_not be_empty
      @preferences.errors_on(:smtp_server).should_not be_empty
    end
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
  
  describe "non-boolean attributes" do
    before(:each) do
      @preferences = Preference.new
    end

    it "should have an analytics field" do
      @preferences.should respond_to(:analytics)
    end
    
    it "should have a blank initial analytics" do
      @preferences.analytics.should be_blank
    end
  end
end
