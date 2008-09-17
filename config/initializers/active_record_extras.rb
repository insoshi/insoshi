class ActiveRecord::Base

  # Build a record unsafely, bypassing attr_accessible.
  # This is useful in tests and in the console.
  def self.unsafe_build(attrs)
    o = new
    o.unsafe_attributes = attrs
    o
  end
  
  def self.unsafe_create(attrs)
    o = unsafe_build(attrs)
    o.save
    o
  end
  
  def self.unsafe_create!(attrs)
    o = unsafe_build(attrs)
    o.save!
  end

  def unsafe_attributes=(attrs)
    attrs.each do |(k,v)|
      send("#{k}=", v)
    end
  end
end