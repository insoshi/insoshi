

class Numeric
  def c(unit = '')
    number_to_currency(self, :unit=>unit)
  end
  def delim
    number_with_delimiter(self)
  end
  
  
  def to_clock
    ret = ''
    total = self.to_s.to_i #so we don't change self
    if total >= 1.hour
      num = (total / 1.hour.to_f).floor
      total -= num * 1.hour
      ret += num.to_s
    else 
      ret = '00'
    end
    if total >= 1.minute
      num = (total / 1.minute.to_f).floor
      total -= num * 1.minute
      ret += ':' + num.to_s.rjust(2, '0')
    else
      ret += ':00'
    end
    if total < 1.minute
      num = total
      ret += ':' + num.to_s.rjust(2, '0')
    else
      ret += ':00'
    end
    
    ret
  end
  
end
