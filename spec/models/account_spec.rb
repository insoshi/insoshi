# == Schema Information
#
# Table name: accounts
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  balance         :decimal(8, 2)    default(0.0)
#  person_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  group_id        :integer
#  credit_limit    :decimal(8, 2)
#  offset          :decimal(8, 2)    default(0.0)
#  paid            :decimal(8, 2)    default(0.0)
#  earned          :decimal(8, 2)    default(0.0)
#  reserve_percent :decimal(8, 7)    default(0.0)
#  reserve         :boolean          default(FALSE)
#  rollover_charge :decimal(, )      default(0.0)
#

require 'spec_helper'

describe Account do
  fixtures :people, :fee_plans, :stripe_fees, :accounts, :memberships
  
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
  
  ['month', 'year'].each do |interval|   
    
   it "should be able to generate #{interval}ly fees invoice for itself" do
     FixedTransactionFee.new(fee_plan: @fee_plan, amount: 1, recipient: @p3).save!
     PercentTransactionFee.new(fee_plan: @fee_plan, percent: 10, recipient: @p3).save!
     FixedTransactionStripeFee.new(fee_plan: @fee_plan, amount: 1).save!
     PercentTransactionStripeFee.new(fee_plan: @fee_plan, percent: 10).save!
     RecurringFee.new(fee_plan: @fee_plan, amount: 1, recipient: @p3, interval: interval).save!
     RecurringStripeFee.new(fee_plan: @fee_plan, amount: 1, interval: interval).save! 
     @e.save!
     StripeFee.apply_stripe_transaction_fees(interval)
     @p.account(@g).fees_invoice_for(interval).should contain(Transact.first.paid_fees)
   end
  end
  
end
