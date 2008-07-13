# Footnotes is divided in three main files:
#
#  * initialiazer.rb: Initialize the plugin and apply the footnotes as an after_filter;
#
#  * footnotes.rb: Is the core and adds the debug options at the bottom of each page;
#
#  * backtracer.rb: Append links to tour favorite editor in backtrace pages.
#
if (ENV['RAILS_ENV'] == 'development')
  dir = File.dirname(__FILE__)
  require File.join(dir,'lib','footnotes')
  require File.join(dir,'lib','loader')
  require File.join(dir,'lib','backtracer')

  Footnotes::Filter.prefix ||= 'txmt://open?url=file://' if RUBY_PLATFORM.include?('darwin') 
end