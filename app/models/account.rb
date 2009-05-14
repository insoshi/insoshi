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

  INITIAL_BALANCE = 0

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

  def self.transfer(from, to, amount, req)
    transaction do
      from.withdraw(amount)
      to.deposit(amount)

      exchange = Exchange.new()
      exchange.customer = from.person
      exchange.worker = to.person
      exchange.amount = amount
      exchange.req = req
      exchange.save!
    end
  end
end
