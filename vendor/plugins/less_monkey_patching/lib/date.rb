class Date
  def d(format = '%m/%d/%y')
    self.strftime(format)
  end
  
#duplication of rails' time calculation methods
  def months_since(months)
    year, month, mday = self.year, self.month, self.mday

    month += months

    # in case months is negative
    while month < 1
      month += 12
      year -= 1
    end

    # in case months is positive
    while month > 12
      month -= 12
      year += 1
    end

    max = ::Time.days_in_month(month, year)
    mday = max if mday > max

    change(:year => year, :month => month, :mday => mday)
  end

  def next_month
    months_since(1)
  end

  def last_month
    months_ago(1)
  end

  def months_ago(months)
    months_since(-months)
  end
  
  def change(options)
    Date.new(
      options[:year]  || self.year, 
      options[:month] || self.month, 
      options[:mday]  || self.mday
    )
  end
#end duplication of rails' time calculation methods



  def last_week
    self - 7
  end
  
  def next_week
    self + 7    
  end

  def to_formatted_date(format=nil)
    self
  end
end
