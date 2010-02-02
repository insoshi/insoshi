require 'test/unit'
require "rubygems"
require 'active_support'

for file in ["../lib/delete_file_column.rb", "mock_model.rb"]
  require File.expand_path(File.join(File.dirname(__FILE__), file))
end



def dbg
  require 'ruby-debug'
  Debugger.start
  debugger
end
