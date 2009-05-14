class ActiveRecord::Base

  # Build and create records unsafely, bypassing attr_accessible.
  # These methods are especially useful in tests and in the console.
  
  def self.unsafe_build(attrs)
    record = new
    record.unsafe_attributes = attrs
    record
  end
  
  def self.unsafe_create(attrs)
    record = unsafe_build(attrs)
    record.save
    record
  end
  
  def self.unsafe_create!(attrs)
    unsafe_build(attrs).save!
  end

  def unsafe_attributes=(attrs)
    attrs.each do |k, v|
      send("#{k}=", v)
    end
  end
end