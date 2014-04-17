class FeePlan < ActiveRecord::Base
  validates_presence_of	:name
  validates_length_of :name,  :maximum => 100
  validates_length_of :description,  :maximum => 255
  validate :child_class_errors
  has_many :people, :dependent => :restrict
  has_many :fees
  has_many :stripe_fees
  has_many :fixed_transaction_stripe_fees, :dependent => :destroy, :inverse_of => :fee_plan
  has_many :percent_transaction_stripe_fees, :dependent => :destroy, :inverse_of => :fee_plan
  has_many :recurring_stripe_fees, :dependent => :destroy, :inverse_of => :fee_plan
  has_many :fixed_transaction_fees, :dependent => :destroy, :inverse_of => :fee_plan
  has_many :percent_transaction_fees, :dependent => :destroy, :inverse_of => :fee_plan
  has_many :recurring_fees, :dependent => :destroy, :inverse_of => :fee_plan
  
  accepts_nested_attributes_for :recurring_fees
  accepts_nested_attributes_for :recurring_stripe_fees
  accepts_nested_attributes_for :fixed_transaction_fees
  accepts_nested_attributes_for :percent_transaction_fees
  accepts_nested_attributes_for :fixed_transaction_stripe_fees
  accepts_nested_attributes_for :percent_transaction_stripe_fees

  default_scope :order => 'name ASC'

  def apply_recurring_fees(interval)
    group = Preference.first.default_group
    recurring_fees.each do |f|
      if interval == f.interval
        self.people.each do |payer|
          e=group.exchanges.build(amount: f.amount)
          e.customer = payer
          e.worker = f.recipient
          e.notes = "#{interval.capitalize}ly recurring fee"
          e.save!
        end
      end
    end
  end

  def apply_transaction_fees(txn)
    percent_transaction_fees.each do |fee|
        e=txn.group.exchanges.build(amount: txn.amount*fee.percent)
        e.metadata = txn.metadata
        e.customer = txn.worker
        e.worker = fee.recipient
        e.notes = 'Percent transaction fee'
        e.save!
    end

    fixed_transaction_fees.each do |fee|
        e=txn.group.exchanges.build(amount: fee.amount)
        e.metadata = txn.metadata
        e.customer = txn.worker
        e.worker = fee.recipient
        e.notes = 'Fixed transaction fee'
        e.save!
    end
  end
  
  def contains_stripe_fees?
    self.stripe_fees.any? ||
    self.fixed_transaction_stripe_fees.any? ||
    self.percent_transaction_stripe_fees.any? ||
    self.recurring_stripe_fees.any?
  end
  
  def all_fees
    @all ||= self.fees + self.stripe_fees
  end
  
  def subscribe_payers_to_stripe(recurring_stripe_fee_id)
    self.people.subscribed_to_stripe.each do |person|
      StripeOps.subscribe_to_plan(person.stripe_id, recurring_stripe_fee_id)
    end
  end
  
  private
  
  def child_class_errors
    ["", "stripe_"].each do |fee_type|
      [:"fixed_transaction_#{fee_type}fees",
       :"percent_transaction_#{fee_type}fees",
       :"recurring_#{fee_type}fees"].each do |fees_in_plan|
        self.send(fees_in_plan).each do |fee|
          fee.valid?
          fee.errors.full_messages.each do |msg|
            self.errors.add(:base, "#{fee.class} error: #{msg}")
          end
        end
      end
    end
  end
  
end
