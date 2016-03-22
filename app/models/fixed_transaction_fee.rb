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

class FixedTransactionFee < Fee
  validates_numericality_of :amount, :greater_than => 0
  belongs_to :fee_plan, :inverse_of => :fixed_transaction_fees
end
