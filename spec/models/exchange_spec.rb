# Issues 325 and 332 (credit limit being exceeded and admin override for credit limit)

# Credit limit not being respected (at 0 or a positive number)

# Admin should be able to create an exchange even if it exceeds the user's credit limit if they check a box specifying this.


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

  it  "should allow the customer to spend more that their credit limit if a flag is set" do
  end
end
