require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ActionsTest < Test::Unit::TestCase
  def setup
    @actions = ActiveScaffold::DataStructures::Actions.new(:a, 'b')
  end

  def test_initialization
    assert @actions.include?('a')
    assert @actions.include?(:b)
    assert !@actions.include?(:c)
  end

  def test_exclude
    assert @actions.include?('b')
    @actions.exclude :b
    assert !@actions.include?(:b)
  end

  def test_add
    assert !@actions.include?(:c)
    @actions.add 'c'
    assert @actions.include?('c')
  end
end