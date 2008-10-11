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
