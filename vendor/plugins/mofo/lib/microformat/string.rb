require File.dirname(__FILE__) + '/time'

class String
  def coerce
    return true if self == 'true'
    return false if self == 'false'
    coerce_try { return Time.iso8601(self) }
    coerce_try { return Integer(self) }
    coerce_try { return Float(self) }
    self
  end

  def strip_html
    gsub(/<(?:[^>'"]*|(['"]).*?\1)*>/,'')
  end

private

  def coerce_try
    yield
  rescue
    nil
  end
end
