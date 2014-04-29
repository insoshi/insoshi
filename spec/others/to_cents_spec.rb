require File.dirname(__FILE__) + '/../spec_helper'

describe Numeric do
  describe "to_cents" do
    it "should return cents number from amount in dollars." do
      40.25.to_cents.should == 4025
      40.3242943279438.to_cents.should == 4032
      40.32639048240328084.to_cents.should == 4033
    end
  end
end