# == Schema Information
#
# Table name: fee_plans
#
#  id          :integer          not null, primary key
#  name        :string(100)      not null
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  available   :boolean          default(FALSE)
#

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

  before_destroy :subscribe_people_to_default_plan
  default_scope :order => 'name ASC'

  class << self

    def daily_check_for_recurring_fees(time)
      Person.all.each do |person|
        FeeSchedule.new(person).charge
      end
    end
  end

  def does_not_include_bogus_recurring_stripe_fee
    if has_a_recurring_stripe_fee?
      recurring_stripe_fees.each do |stripe_fee|
        stripe_plan = Stripe::Plan.retrieve(stripe_fee.plan)
      end
    end
  rescue Stripe::InvalidRequestError => e
    Rails.logger.info "does_not_include_bogus_recurring_stripe_fee: #{e.message}"
    errors.add(:enabled, "cannot be set with stripe plan that does not exist")
  end

  default_scope :order => 'name ASC'

  def recurring_fees
    @recurring_fees ||= self.fees.where(:type => "RecurringFee")
  end

  def apply_transaction_fees(txn, customer)
    percent_transaction_fees = self.fees.where(:type => "PercentTransactionFee")
    fixed_transaction_fees = self.fees.where(:type => "FixedTransactionFee")
    percent_transaction_fees.each do |fee|
        e=txn.group.exchanges.build(amount: txn.amount*fee.percent)
        e.metadata = txn
        e.customer = customer
        e.worker = fee.recipient
        e.notes = 'Percent transaction fee'
        e.save!
    end

    fixed_transaction_fees.each do |fee|
        e=txn.group.exchanges.build(amount: fee.amount)
        e.metadata = txn
        e.customer = customer
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

  def subscribe_people_to_default_plan
    default_plan = FeePlan.find_by_name("default")
    self.people.each do |person|
      person.fee_plan = default_plan
      person.save!
    end
  end

end
