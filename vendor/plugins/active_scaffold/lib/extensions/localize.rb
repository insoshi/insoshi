class Object
  def as_(key, options = {})
    unless key.blank?
      text = I18n.translate "#{key}", {:scope => [:active_scaffold], :default => key.is_a?(String) ? key : key.to_s.titleize}.merge(options)
      # text = nil if text.include?('translation missing:')
    end
    text ||= key 
    text
  end
end
