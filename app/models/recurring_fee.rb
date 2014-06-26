class RecurringFee < Fee
  validates_numericality_of :amount, :greater_than => 0
  validates :interval, inclusion: { in: ['month', 'year'], message: "%{value} is not a valid interval." }
  belongs_to :fee_plan, :inverse_of => :recurring_fees
end
