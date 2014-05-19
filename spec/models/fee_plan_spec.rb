require 'spec_helper'
require 'cancan/matchers'

describe FeePlan do
  fixtures :people

  before(:each) do
    @valid_attributes = {
      name: 'plan1'
    }
    @p = people(:admin)
  end

  it "should create a new instance given valid attributes" do
    fee_plan = FeePlan.create!(@valid_attributes)
  end

  it "should include both stripe fees and trade credit fees" do
    fee_plan = FeePlan.create!(@valid_attributes)
    tc_fee = Fee.create!(fee_plan: fee_plan, recipient: people(:quentin))
    stripe_fee = StripeFee.create!(fee_plan: fee_plan)
    fee_plan.all_fees.should include tc_fee
    fee_plan.all_fees.should include stripe_fee
    fee_plan.contains_stripe_fees?.should be_true
  end

  it "should detect end of month given end of month" do
    today = Date.new(2014,5,31)
    FeePlan.daily_check_for_recurring_fees(today).should include('month')
  end

  it "should not detect end of year given end of month" do
    today = Date.new(2014,5,31)
    FeePlan.daily_check_for_recurring_fees(today).should_not include('year')
  end

  it "should detect end of year and end of month given end of year" do
    today = Date.new(2014,12,31)
    FeePlan.daily_check_for_recurring_fees(today).should include('year','month')
  end

  it "should not detect end of month given first of month" do
    today = Date.new(2014,5,1)
    FeePlan.daily_check_for_recurring_fees(today).should be_empty
  end
end
