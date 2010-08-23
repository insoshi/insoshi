module ExchangesHelper
  def exchanges_chart_series(exchanges,day)
    exchanges_by_day = exchanges.sum("amount",:group => "date(created_at)",:conditions => ["date(created_at) > ?", day])
    (day..Date.today).map do |date|
      exchanges_by_day[date.to_s].to_f || 0
    end.inspect
  end

  def monthly_exchanges_for_year(year)
    (1..12).map {|month| Exchange.total_on_month(year+"-"+month.to_s+"-"+"01").to_f}.inspect
  end
end
