# == Schema Information
# Schema version: 20090216032013
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     
#  balance    :decimal(8, 2)   default(0.0)
#  person_id  :integer(4)      
#  created_at :datetime        
#  updated_at :datetime        
#

class Account < ActiveRecord::Base
  belongs_to :person
  belongs_to :group

  attr_accessible :credit_limit

  before_update :check_credit_limit

  INITIAL_BALANCE = 0

  def membership
    Membership.mem(person,group)
  end

  def authorized?(amount)
    credit_limit.nil? or (amount <= balance + credit_limit)
  end

  def withdraw(amount)
    adjust_balance_and_save(-amount)
  end

  def deposit(amount)
    adjust_balance_and_save(amount)
  end

  def adjust_balance_and_save(amount)
    self.balance += amount
    save!
  end

  def self.transfer(from, to, amount, metadata)
    transaction do
      exchange = Exchange.new()
      exchange.customer = from
      exchange.worker = to
      exchange.amount = amount
      exchange.metadata = metadata
      exchange.group_id = metadata.group_id
      # permission depends on current_user and policy of group specified in request
      if metadata.ability.can? :create, exchange
        exchange.save!
      else
        raise CanCan::AccessDenied.new("Payment declined.", :create, Exchange)
      end
    end
  end

  private

  def check_credit_limit 
    if credit_limit_changed?
      if (not credit_limit.nil?) and (credit_limit + balance < 0)
        raise CanCan::AccessDenied.new("Denied: Updating credit limit for #{person.name} would put account in prohibited state.", :update, Account)
      end
    end
  end
end
