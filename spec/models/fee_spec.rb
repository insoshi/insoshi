require 'spec_helper'

describe Fee do
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
  end

  it "should be associated with a fee plan" do
    fee = Fee.new(fee_plan: nil)
    fee.should_not be_valid
  end
  
  it "should convert percent number to percents before saving" do
    @fee_plan = FeePlan.new(name: 'test')
    fee = Fee.new(fee_plan: @fee_plan, percent: 10, recipient: @p3)
    fee.percent.to_f.should == 10.0
    fee.save!
    fee.percent.to_f.should == 0.1
  end
  
  describe 'trade credits fee' do
    before(:each) do
      @fee_plan = FeePlan.new(name: 'test')
      @fee_plan.save!
      @p.fee_plan = @fee_plan
      @p.save!
      @e = @g.exchange_and_fees.build(amount: 2.0)
      @e.worker = @p
      @e.customer = @p2
      @e.notes = 'Generic'
    end
    
    it "should charge the recipient a fixed transaction fee" do
      fee = FixedTransactionFee.new(fee_plan: @fee_plan, amount: 0.1, recipient: @p3)
      fee.save!
      @e.save!
      account_after_payment = @p.account(@g)
      account_after_payment.balance.should == 1.9
    end
    
    it "should charge the recipient a percentage transaction fee" do
      fee = PercentTransactionFee.new(fee_plan: @fee_plan, percent: 10, recipient: @p3)
      fee.save!
      @e.save!
      # Without fee it's 2.0. Fee is 10%, so 2.0 - 10% * 2.0 = 1.8
      account_after_payment = @p.account(@g)
      account_after_payment.balance.should == 1.8
    end
    
    ['month', 'year'].each do |interval|
      
      it "should charge the recipient a #{interval}ly fixed recurring fee" do
        fee = RecurringFee.new(fee_plan: @fee_plan, amount: 0.1, recipient: @p3, interval: interval)
        fee.save!
        @e.save!
        @fee_plan.apply_recurring_fees(interval)
        account_after_payment = @p.account(@g)
        account_after_payment.balance.should == 1.9
      end
      
      it "should be included in #{interval}ly billing history of fees" do
        fixed_fee = FixedTransactionFee.new(fee_plan: @fee_plan, amount: 0.1, recipient: @p3)
        fixed_fee.save!
        percent_fee = PercentTransactionFee.new(fee_plan: @fee_plan, percent: 10, recipient: @p3)
        percent_fee.save!
        @e.save!
        Fee.transaction_tc_fees_sum_for(@p, interval).should == 0.3
      end
  
    end
  end

end