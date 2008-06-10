class Array
  def first_or_self
    size > 1 ? self : first
  end
end
