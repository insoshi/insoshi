
class FeeSchedule
  def initialize(person)
    @person = person
    @fee_plan = person.fee_plan
  end

  def charge
    group = Preference.first.default_group
    if @fee_plan.recurring_fees
      @fee_plan.recurring_fees.each do |fee|
        if charge_today?(fee.interval, Date.today)
          e = group.exchanges.build(amount: f.amount)
          e.customer = person
          e.worker = fee.recipient
          e.notes = "#{interval.capitalize}ly recurring fee"
          e.save!
        end
      end
    end
  end

  def charge_today?(interval, date)
    case interval
    when 'month'
      if [29, 30, 31].include?(@person.plan_started_at.day)
        date.day == 28
      else
        date.day == @person.plan_started_at.day
      end
    when 'year'
      if @person.plan_started_at.yday == 366
        date.yday == 365
      else
        date.yday == @person.plan_started_at.yday
      end
    end
  end
end