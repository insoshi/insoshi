# This overrides the :per_page attribute for will_paginate.
# The default for will_paginate is 30, which seems a little high.
class ActiveRecord::Base
  def self.per_page
    10
  end
end

# This enables i18n support for previous_label and next_label for will_paginate.
WillPaginate::ViewHelpers.pagination_options[:previous_label] = '&laquo; ' + I18n.t('pagination.previous')
WillPaginate::ViewHelpers.pagination_options[:next_label] = I18n.t('pagination.next') + ' &raquo'
