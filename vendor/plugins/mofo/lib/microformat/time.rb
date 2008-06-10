require 'time'

class Time
  ISO8601_REGEX = /^\d{4}-?\d{2}-?\d{2}(T\d{2}(:?\d{2}(:?\d{2}(\.?\d{2})?)?)?(Z|[+-]\d{2}(:?\d{2})?)?)?$/
  
  def self.iso8601(a_string)
    raise ArgumentError unless a_string =~ ISO8601_REGEX

    Time.xmlschema(a_string) rescue Time.parse(a_string)
  end
end
