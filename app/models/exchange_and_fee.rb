class ExchangeAndFee < Exchange
  after_create :withdraw_fee

  def withdraw_fee
    group.accounts.where(reserve: true).each do |a|
      e=group.exchanges.build(amount: a.reserve_percent)
      e.metadata = metadata
      e.customer = worker
      e.worker = a.person
      e.save!
    end
  end
end
