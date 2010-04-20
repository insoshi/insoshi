##
## Initialize the environment
##
unless Rails::VERSION::MAJOR == 2 && Rails::VERSION::MINOR >= 3
  raise "This version of ActiveScaffold requires Rails 2.3 or higher.  Please use an earlier version."
end

require File.dirname(__FILE__) + '/environment'

##
## Run the install assets script, too, just to make sure
## But at least rescue the action in production
##
begin
  require File.dirname(__FILE__) + '/install_assets'
rescue
  raise $! unless Rails.env == 'production'
end
