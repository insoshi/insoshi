require 'spec_helper'

describe Charge do
  fixtures :people
  before(:each) do
    @p = people(:quentin)
    valid_params = {
      :stripe_id => @p.stripe_id,
      :description => 'test charge',
      :amount => 1,
      :status => 'paid',
      :person_id => @p.id
    }
    @charge = Charge.create(valid_params)
  end
  it "should accept only valid params" do
    @charge.should be_valid
    @charge.status = 'pending'
    @charge.should be_valid
    @charge.status = 'refunded'
    @charge.should be_valid
    @charge.status = 'partially refunded'
    @charge.should be_valid
    @charge.status = 'disputed'
    @charge.should be_valid
    @charge.status = 'dispute success'
    @charge.should_not be_valid
  end
  
  it "should generate link to dispute page" do
    @charge.dispute_link.should == "https://manage.stripe.com/test/payments/" + @charge.stripe_id
  end
  
  it "should has minimum amount as 50 cents." do
    StripeOps.charge(0.49, @p.stripe_id, 'test').should == "Minimum amount that can be submitted via stripe is 50 cents!"
  end
  
  it "should be refundable partially or fully" do
    stripe_ret = StripeOps.charge(1, @p.stripe_id, 'test charge')
    StripeOps.refund_charge(stripe_ret[:id], @charge.amount - 0.01)
    @charge = Charge.find_by_stripe_id(stripe_ret[:id])
    @charge.status.should == "partially refunded"
    @charge.destroy
    stripe_ret = StripeOps.charge(1, @p.stripe_id, 'test charge')
    StripeOps.refund_charge(stripe_ret[:id], @charge.amount)
    @charge = Charge.find_by_stripe_id(stripe_ret[:id])
    @charge.status.should == "refunded"
  end
  
  it "should send user an email after transaction" do
    PersonMailer.deliveries.clear
    StripeOps.charge(1, @p.stripe_id, 'test charge')
    sleep 1
    PersonMailer.deliveries.should_not be_empty
  end
  
end