require File.dirname(__FILE__) + '/../spec_helper'

describe Preference do
  describe "static global preference" do
    it "should prohibit multiple preference objects" do
      @preferences = Preference.new
      @preferences.save.should be_false
      @preferences.errors.full_messages.should include('Attempting to instantiate another Preference object')
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
