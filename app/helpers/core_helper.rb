module CoreHelper
  # If the first argument is an id, finds the corresponding model instance
  # otherwise returns the object itself.
  def coerce(object_or_id, activerecord_class)
    if object_or_id.is_a?(activerecord_class)
      object_or_id
    else
      activerecord_class.find(object_or_id)
    end
  end

end
