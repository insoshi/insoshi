# == Schema Information
#
# Table name: stripe_fees
#
#  id          :integer          not null, primary key
#  fee_plan_id :integer
#  type        :string(255)
#  percent     :decimal(8, 7)    default(0.0)
#  amount      :decimal(8, 2)    default(0.0)
#  interval    :string(255)
#  plan        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class StripeFee < ActiveRecord::Base
  belongs_to :fee_plan
  attr_readonly :fee_plan
  validates :fee_plan, presence: true

  def self.transaction_stripe_fees_sum_for(person, interval)
    today = Date.today
    fees_sum = person.fee_plan.fixed_transaction_stripe_fees.sum(:amount)
    perc_fees_sum = person.fee_plan.percent_transaction_stripe_fees.sum(:percent)
    time_start = today.method("beginning_of_#{interval}").call
    time_end = today.method("end_of_#{interval}").call
    transactions = person.transactions.where(:worker_id => person.id).by_time(time_start, time_end)
    cash_fees_sum = fees_sum * transactions.count
    transactions.each do |transaction|
      cash_fees_sum += perc_fees_sum * transaction.amount
    end
    cash_fees_sum
  end

  # Cash fees are aggregated and submitted to credit card processing in batches.
  # Currently, weekly to Stripe.
  def self.apply_stripe_transaction_fees(interval)
    desc = "#{interval}ly transaction fees sum"
    Person.with_stripe_plans.each do |person|
      amount_to_charge = StripeFee.transaction_stripe_fees_sum_for(person, interval) + person.rollover_balance
      if amount_to_charge > 0.5
        StripeOps.charge(amount_to_charge, person.stripe_id, desc)
        amount_to_charge = 0
      end
      person.rollover_balance = amount_to_charge
      person.save!

    end
  end

  def display_percent
    percent * 100
  end

  def display_percent=(value)
    update_attribute(:percent, value.to_f/100.0)
  end

end
