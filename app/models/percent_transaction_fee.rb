class PercentTransactionFee < Fee
  validates_numericality_of :percent, :greater_than => 0
  belongs_to :fee_plan, :inverse_of => :percent_transaction_fees
end
