class FixedTransactionFee < Fee
  validates_numericality_of :amount, :greater_than => 0
  belongs_to :fee_plan, :inverse_of => :fixed_transaction_fees
end
