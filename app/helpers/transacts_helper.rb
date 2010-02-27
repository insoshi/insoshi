module TransactsHelper
  def counterparty(t)
    counterparty = current_person?(t.worker) ? t.customer : t.worker
  end

  def counterparty_action(t)
    units = t.group.nil? ? t('currency_unit_plural') : t.group.unit
    if current_person?(t.worker)
      "+#{t.amount.to_s} #{units} (" + t('transacts.helper.received_from') + " "
    else
      "-#{t.amount.to_s} #{units} (" + t('transacts.helper.paid_to') + " "
    end
  end
end
