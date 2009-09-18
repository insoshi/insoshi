##
## Initialize the environment
##
raise "This version of ActiveScaffold requires Rails 2.1 or higher.  Please use an earlier version." unless Rails::VERSION::MAJOR == 2 && Rails::VERSION::MINOR >= 1

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
