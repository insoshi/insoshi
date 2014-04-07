require 'spec_helper'

describe StripeFee do
  fixtures :people
  
  it "should be associated with a fee plan" do
    stripe_fee = StripeFee.new(fee_plan: nil)
    stripe_fee.should_not be_valid
  end
  
  it "should convert percent number to percents before saving" do
    @fee_plan = FeePlan.new(name: 'test')
    s_fee = StripeFee.new(fee_plan: @fee_plan, percent: 10)
    s_fee.percent.to_f.should == 10.0
    s_fee.save!
    s_fee.percent.to_f.should == 0.1
  end
  
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
    @e = @g.exchange_and_fees.build(amount: 2.0)
    @e.worker = @p
    @e.customer = @p2
    @e.notes = 'Generic'
  end
  
  describe 'recurring fees' do
      
      it 'should have valid interval' do
        sr_fee = RecurringStripeFee.new(interval: 'month', fee_plan: @fee_plan, amount: 1)
        sr_fee.should be_valid
        sr_fee.interval = 'year'
        sr_fee.should be_valid
        sr_fee.interval = '2 weeks'
        sr_fee.should_not be_valid
      end
      
      before(:each) do
        @sr_fee = RecurringStripeFee.new(interval: 'month', fee_plan: @fee_plan, amount: 1)
        @sr_fee.save!
      end
      
      it 'should create accurate plan on Stripe and subscribe people with fee plan to it' do
        stripe_plan = Stripe::Plan.retrieve(@sr_fee.plan)
        stripe_plan.should be
        Stripe::Customer.retrieve(@p.stripe_id).subscriptions.first.plan[:id].should == @sr_fee.plan
      end
      
      it 'should be able to retrieve amount and interval from stripe' do
        @sr_fee.interval = ''
        @sr_fee.amount = 0
        @sr_fee.retrieve_interval_and_amount
        @sr_fee.interval.should == 'month'
        @sr_fee.amount.should == 1
      end
      
      it 'should destroy plan on stripe after destroying itself' do
        @sr_fee.destroy
        begin
          Stripe::Plan.retrieve(@sr_fee.plan)
        rescue => e
          e.to_s.should include "No such plan"
        end
      end

    end # recurring stripe fees test end
  
  describe 'stripe paid fees' do
    
    ['month', 'year'].each do |interval|
       
      it "should be included in #{interval}ly billing history of fees" do
        s_fixed_fee = FixedTransactionStripeFee.new(fee_plan: @fee_plan, amount: 1)
        s_fixed_fee.save!
        s_percent_fee = PercentTransactionStripeFee.new(fee_plan: @fee_plan, percent: 10)
        s_percent_fee.save!
        @e.save!
        sum = StripeFee.transaction_stripe_fees_sum_for(@p, interval)
        sum.should == 1.2
      end
      
      it "should charge the recipient a #{interval}ly fixed transaction stripe fee" do
        s_fee = FixedTransactionStripeFee.new(fee_plan: @fee_plan, amount: 1)
        s_fee.save!
        @e.save!
        StripeFee.apply_stripe_transaction_fees(interval)
        desc = "#{interval}ly transaction fees sum"
        StripeOps.all_charges_for_person(@p.stripe_id).last.should include desc
        Charge.all_charges_for(@p.id, interval).last[:desc].should == desc
      end  
    end 
  end
end
