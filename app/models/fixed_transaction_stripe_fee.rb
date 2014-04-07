class FixedTransactionStripeFee < StripeFee
  validates_numericality_of :amount, :greater_than => 0.5, message: "Minimal Stripe fee is 0.5$"
  belongs_to :fee_plan, :inverse_of => :fixed_transaction_stripe_fees
end
