require 'active_support'
require 'active_support/inflector'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable %w(oauth)
end
