class ActiveRecord::Errors
  
  def to_s
    full_messages.join("\n")
  end
end