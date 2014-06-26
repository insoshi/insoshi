class PercentTransactionStripeFee < StripeFee
  validates_numericality_of :percent, :greater_than => 0
  belongs_to :fee_plan, :inverse_of => :percent_transaction_stripe_fees
end
