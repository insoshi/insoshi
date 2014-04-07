module TransactsHelper
  def counterparty(t)
    counterparty = current_person?(t.worker) ? t.customer : t.worker
  end

  def counterparty_action(t)
    units = t.group.nil? ? t('currency_unit_plural') : t.group.unit
    if current_person?(t.worker)
      "+#{nice_decimal(t.amount)} #{units} (" + t('transacts.helper.received_from') + " "
    else
      "-#{nice_decimal(t.amount)} #{units} (" + t('transacts.helper.paid_to') + " "
    end
  end

  def counterparty_link(counterparty, group, ajaxified)
    if ajaxified
      link_to counterparty.name, Membership.mem(counterparty, group), :class => 'show-follow'
    else
      link_to counterparty.name, counterparty
    end
  end
  
  def paid_fees(transact)
    fees = transact.paid_fees
    unless fees.blank?
      "Charged fees: Trade Credits: #{fees[:"trade-credits"]} Cash: #{fees[:cash]}$"
    end
  end
end
