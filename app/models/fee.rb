# == Schema Information
#
# Table name: fees
#
#  id           :integer          not null, primary key
#  fee_plan_id  :integer
#  type         :string(255)
#  recipient_id :integer
#  percent      :decimal(8, 7)    default(0.0)
#  amount       :decimal(8, 2)    default(0.0)
#  interval     :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Fee < ActiveRecord::Base
  belongs_to :fee_plan
  belongs_to :recipient, :class_name => 'Person', :foreign_key => 'recipient_id'
  attr_readonly :fee_plan
  validates :fee_plan, presence: true
  validates :recipient, presence: true


  def self.transaction_tc_fees_sum_for(person, interval)
    today = Date.today
    fees_sum = person.fee_plan.fixed_transaction_fees.sum(:amount)
    perc_fees_sum = person.fee_plan.percent_transaction_fees.sum(:percent)
    time_start = today.method("beginning_of_#{interval}").call
    time_end = today.method("end_of_#{interval}").call
    transactions = person.transactions.where(:worker_id => person.id).by_time(time_start, time_end)
    tc_fees_sum = fees_sum * transactions.count
    transactions.each do |transaction|
      tc_fees_sum += perc_fees_sum * transaction.amount
    end
    tc_fees_sum
  end

  def display_percent
    percent * 100
  end

  def display_percent=(value)
    update_attribute(:percent, value.to_f/100.0)
  end
end
