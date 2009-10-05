module TransactsHelper
  def counterparty(t)
    counterparty = current_person?(t.worker) ? t.customer : t.worker
  end

  def counterparty_action(t)
    units = t.group.nil? ? "hours" : t.group.unit
    if current_person?(t.worker)
      "+#{t.amount.to_s} #{units} (received from "
    else
      "-#{t.amount.to_s} #{units} (paid to "
    end
  end
end
