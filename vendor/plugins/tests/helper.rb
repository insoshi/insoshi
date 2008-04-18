require 'test/unit'
require 'rubygems'

# gem install redgreen for colored test output
#begin require 'redgreen'; rescue LoadError; end

dirname = File.dirname(__FILE__)

# add plugin's main lib dir to load paths
$:.unshift(File.join(dirname, '..', 'lib')).uniq!




class LessTests < Test::Unit::TestCase

  # Default so Test::Unit::TestCase doesn't complain
  def test_truth
  end
end
