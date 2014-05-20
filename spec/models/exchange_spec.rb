require File.dirname(__FILE__) + '/../spec_helper'

describe Exchange do

  fixtures :people, :accounts, :groups, :memberships

  before(:each) do
    @customer = people(:frank)
    @worker = people(:doug)
  end

  it "should be invalid if the customer does not have enough credit" do
    exchange = Exchange.new(amount: 10, group_id: groups(:one).id)
    exchange.worker = @worker
    exchange.customer = @customer

    exchange.should have(1).error_on(:customer)
    exchange.errors.full_messages.join(' ').should match(/insufficient balance/)
  end

  it "should be valid if the account offset covers the amount" do
    @customer.account(groups(:one)).update_attribute(:offset, 10)

    exchange = Exchange.new(amount: 10, group_id: groups(:one).id)
    exchange.worker = @worker
    exchange.customer = @customer

    exchange.should be_valid
  end

  pending "should allow the customer to spend more that their credit limit if a flag is set" do
  end
end
