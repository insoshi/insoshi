# == Schema Information
#
# Table name: exchanges
#
#  id            :integer          not null, primary key
#  customer_id   :integer
#  worker_id     :integer
#  amount        :decimal(8, 2)    default(0.0)
#  created_at    :datetime
#  updated_at    :datetime
#  group_id      :integer
#  metadata_id   :integer
#  metadata_type :string(255)
#  deleted_at    :time
#  notes         :string(255)
#  wave_all_fees :boolean          default(FALSE)
#

class ExchangeAndFee < Exchange
  extend PreferencesHelper
  after_create :withdraw_fee, unless: :wave_all_fees
  after_destroy :destroy_relevant_fees, unless: :wave_all_fees

  def withdraw_fee
    # group level transaction fees that apply to all group members
    # this is configured through group admin rather than rails admin
    group.accounts.where(reserve: true).each do |a|
      e=group.exchanges.build(amount: amount*a.reserve_percent)
      e.metadata = metadata
      e.customer = worker
      e.worker = a.person
      e.save!
    end

    # configured through rails_admin
    fee_plan = worker.fee_plan
    if fee_plan
      # assuming systemwide per-transaction fees only apply to default group
      if group_id == ExchangeAndFee.global_prefs.default_group_id
        fee_plan.apply_transaction_fees(self, worker) # note worker
      end
    end

    # customer transaction fees
    customer_fee_pan = customer.fee_plan
    if customer_fee_pan
      # assuming systemwide per-transaction fees only apply to default group
      if group_id == ExchangeAndFee.global_prefs.default_group_id
        customer_fee_pan.apply_transaction_fees(self, customer) # note customer
      end
    end
  end

  private

    def destroy_relevant_fees
      ExchangeAndFee.where(metadata_type: 'Exchange', metadata_id: id).each do |fee|
        fee.deleted_at = deleted_at
        fee.save!
      end
    end
end
