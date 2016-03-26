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

class PercentTransactionStripeFee < StripeFee
  validates_numericality_of :percent, :greater_than => 0
  belongs_to :fee_plan, :inverse_of => :percent_transaction_stripe_fees
end
