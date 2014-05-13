require File.dirname(__FILE__) + '/../spec_helper'

describe Exchange do

  fixtures :people, :accounts, :groups, :memberships

  it "should be invalid if the customer does not have enough credit" do
    customer = people(:frank)
    worker = people(:doug)
    exchange = Exchange.new(amount: 10, group_id: groups(:one).id)
    exchange.worker = worker
    exchange.customer = customer

    exchange.should have(1).error_on(:customer)
    exchange.errors.full_messages.join(' ').should match(/insufficient credit/)
  end

  pending "should allow the customer to spend more that their credit limit if a flag is set" do
  end
end
