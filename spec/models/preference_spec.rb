require File.dirname(__FILE__) + '/../spec_helper'

describe Preference do
  before(:each) do
    @preference = Preference.new
  end

  it "should be valid" do
    @preference.should be_valid
  end
end
