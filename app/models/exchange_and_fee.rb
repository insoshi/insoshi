class ExchangeAndFee < Exchange
  extend PreferencesHelper
  after_create :withdraw_fee

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
    unless fee_plan.nil?
      # assuming systemwide per-transaction fees only apply to default group
      if group_id == ExchangeAndFee.global_prefs.default_group_id
        fee_plan.apply_transaction_fees(self)
      end
    end
  end
end
