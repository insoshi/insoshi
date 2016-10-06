class TransactDecorator < Draper::Decorator
  def unit
    group.nil? ? I18n.t('currency_unit_plural') : group.unit
  end
end
