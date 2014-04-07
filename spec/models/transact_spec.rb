require 'spec_helper'

describe Transact do
  include TransactsHelper # to not repeat before's in helper just to test one statement
  fixtures :people
  
  before(:each) do
    @p = people(:quentin)
    @p2 = people(:aaron)
    @p3 = people(:kelly)
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :mode => Group::PUBLIC,
      :unit => "value for unit",
      :asset => "coins",
      :adhoc_currency => true
    }
    @g = Group.new(@valid_attributes)
    @g.owner = @p
    @g.save!
    Membership.request(@p2,@g,false)
    Membership.request(@p3,@g,false)

    @pref = Preference.first
    @pref.default_group_id = @g.id
    @pref.save!
    @fee_plan = FeePlan.new(name: 'test')
    @fee_plan.save!
    @p.fee_plan = @fee_plan
    @p.save!
    @e = @g.exchange_and_fees.build(amount: 10.0)
    @e.worker = @p
    @e.customer = @p2
    @e.notes = 'Generic'
  end
  
  it "should generate fees invoice for itself and has helper to convert it to nice statement" do
    tc_fixed_fee = FixedTransactionFee.new(fee_plan: @fee_plan, amount: 1, recipient: @p3)
    tc_perc_fee = PercentTransactionFee.new(fee_plan: @fee_plan, percent: 10, recipient: @p3)
    cash_fixed_fee = FixedTransactionStripeFee.new(fee_plan: @fee_plan, amount: 1)
    cash_perc_fee = PercentTransactionStripeFee.new(fee_plan: @fee_plan, percent: 10)
    tc_fixed_fee.save!
    tc_perc_fee.save!
    cash_fixed_fee.save!
    cash_perc_fee.save!
    @e.save!
    t = Transact.first
    t.paid_fees.should == {:"trade-credits" => 2, :cash => 2, :txn_id => t.id}
    paid_fees(t).should == "Charged fees: Trade Credits: 2.0 Cash: 2.0$"
  end
  
end