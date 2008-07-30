class String
  def to_safe_uri
    self.strip.downcase.gsub('&', 'and').gsub(' ', '-').gsub(/[^\w-]/,'')
  end
end