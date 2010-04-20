##
## Install ActiveScaffold assets into /public 
##

require File.dirname(__FILE__) + '/install_assets'

##
## Install Counter
##
#
# What's going on here? 
#   We're incrementing a web counter so we can track SVN installs of ActiveScaffold 
# 
# How? 
#   We're making a GET request to errcount.com to update a simple counter. No data is transmitted.
# 
# Why?
#   So we can know how many people are using ActiveScaffold and modulate our level of effort accordingly.
#   Despite numerous pleas our Googly overlords still only provide us with download stats for the zip distro.
# 
# *Thanks for your understanding* 
#

class ErrCounter # using errcount.com
  require "net/http"
  
  @@ACCOUNT_ID = 341
  @@SITE_DOMAIN = 'installs.activescaffold.com'
  
  def self.increment
    @http = Net::HTTP.new("errcount.com")
    resp, data = @http.get2("/ctr/#{@@ACCOUNT_ID}.js", {'Referer' => @@SITE_DOMAIN})
  end  
end

begin
  ErrCounter.increment
rescue
end
