
class BigDecimal
  def c(unit = '')
    number_to_currency(self, :unit=>unit)
  end
  def delim
    number_with_delimiter(self)
  end
end