require File.join(File.dirname(__FILE__), '../test_helper.rb')

class Config::BaseTest < Test::Unit::TestCase
  def setup
    @base = ActiveScaffold::Config::Base.new
  end
  
  def test_formats
    assert_equal [], @base.formats
    @base.formats << :pdf
    assert_equal [:pdf], @base.formats
    @base.formats = [:html]
    assert_equal [:html], @base.formats
  end
end
