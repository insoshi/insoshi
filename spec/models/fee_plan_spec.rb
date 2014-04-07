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
  
  
end
