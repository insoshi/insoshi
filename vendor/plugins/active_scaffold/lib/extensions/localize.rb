class Object
  def as_(string_to_localize, *args)
    args.empty? ? string_to_localize : (sprintf string_to_localize, *args)
  end
end
