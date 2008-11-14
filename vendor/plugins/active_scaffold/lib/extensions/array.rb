class Array
  # returns the value after the given value. wraps around. defaults to first element in array.
  def after(value)
    return nil unless include? value
    self[(index(value).to_i + 1) % length]
  end
end