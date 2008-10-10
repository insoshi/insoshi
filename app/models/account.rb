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

  def self.transfer(from, to, amount)
    transaction do
      from.withdraw(amount)
      to.deposit(amount)
    end
  end
end
