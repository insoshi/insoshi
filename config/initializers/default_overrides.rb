# This overrides the :per_page attribute for will_paginate.
# The default for will_paginate is 30, which seems a little high.
class ActiveRecord::Base
  def self.per_page
    10
  end
end 