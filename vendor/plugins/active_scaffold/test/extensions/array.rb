require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ArrayTest < Test::Unit::TestCase
  def test_after
    @sequence = ['a', 'b', 'c']

    assert_equal 'b', @sequence.after('a')
    assert_equal 'c', @sequence.after('b')
    assert_equal 'a', @sequence.after('c')
    assert_equal nil, @sequence.after('d')
  end
end