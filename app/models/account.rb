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
  extend PreferencesHelper
  belongs_to :person
  belongs_to :group

  attr_accessible :credit_limit, :offset, :reserve, :reserve_percent, :as => :admin
  attr_accessible :credit_limit, :offset, :reserve, :reserve_percent

  before_update :check_credit_limit

  INITIAL_BALANCE = 0

  def name
    unless read_attribute(:name).blank?
      read_attribute(:name)
    else
      person.display_name if person
    end
  end

  def membership
    Membership.mem(person,group)
  end

  def balance_with_initial_offset
    balance + offset
  end

  def authorized?(amount)
    credit_limit.nil? or (amount <= balance_with_initial_offset + credit_limit)
  end

  def withdraw(amount)
    self.paid += amount
    adjust_balance_and_save(-amount)
  end

  def withdraw_and_decrement_earned(amount)
    self.earned -= amount
    adjust_balance_and_save(-amount)
  end

  def deposit(amount)
    self.earned += amount
    adjust_balance_and_save(amount)
  end

  def deposit_and_decrement_paid(amount)
    self.paid -= amount
    adjust_balance_and_save(amount)
  end

  def adjust_balance_and_save(amount)
    self.balance += amount
    save!
  end

  def self.transfer(from, to, amount, metadata)
    transaction do
      exchange = ExchangeAndFee.new()
      exchange.customer = from
      exchange.worker = to
      exchange.amount = amount
      exchange.metadata = metadata
      # XXX maybe cleaner to let the exchange object assign group_id itself?
      exchange.group_id = metadata.group.adhoc_currency? ? metadata.group_id : global_prefs.default_group_id
      # permission depends on current_user and policy of group specified in request
      if metadata.ability.can? :create, exchange
        exchange.save!
      else
        raise CanCan::AccessDenied.new("Payment declined.", :create, Exchange)
      end
    end
  end
  
  def fees_invoice_for(interval)
    all_fees = Array.new
    today = Date.today
    person.transactions.where(:worker_id => person.id)
          .by_time(today.method("beginning_of_#{interval}").call, today.method("end_of_#{interval}").call)
          .each { |txn| all_fees << txn.paid_fees }
    all_fees
 end
  
  def fees_sum_invoice_for(interval)
    # All transaction fees aggregated for whole month for the customer.
    cash_transaction_fees = Charge.charges_sum_for(person_id, interval)
    tc_transaction_fees = Fee.transaction_tc_fees_sum_for(person, interval)
    # Take month fees too.
    recurring_tc_fees = person.fee_plan.recurring_fees.where(:interval => interval).sum(:amount)
    recurring_cash_fees = person.fee_plan.recurring_stripe_fees.where(:interval => interval).sum(:amount)
    # Nice hash for user.
    { :transactions => { :"trade-credits" => tc_transaction_fees, 
                        :cash => cash_transaction_fees },
      :"#{interval}" => { :"trade-credits" => recurring_tc_fees,
                         :cash => recurring_cash_fees } }  
  end

  private

  def check_credit_limit 
    if credit_limit_changed?
      if (not credit_limit.nil?) and (credit_limit + balance_with_initial_offset < 0)
        raise CanCan::AccessDenied.new("Denied: Updating credit limit for #{person.display_name} would put account in prohibited state.", :update, Account)
      end
    end
  end
  
end
