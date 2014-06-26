require File.dirname(__FILE__) + '/../spec_helper'

describe Numeric do
  describe "to_percents" do
    it "should return given value divided by 100." do
      40.to_percents.should == 0.4
    end
  end
end