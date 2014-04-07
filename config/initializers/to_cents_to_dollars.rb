class Numeric
  def to_cents
    (self.round(2) * 100).to_i
  end
  def to_dollars
    self.to_f / 100
  end
end