class SameYearValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value

    unless value.try(:year) == Time.zone.now.year
      record.errors[attribute] << (options[:message] || 'is a different year')
    end
  end
end
