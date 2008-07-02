require 'test/unit'
require 'rubygems'
require 'mocha'

ENV["RAILS_ENV"] = "test"

require 'active_support'
require File.dirname(__FILE__) + '/../lib/footnotes'
require File.dirname(__FILE__) + '/../lib/notes/abstract_note'