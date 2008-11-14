require File.join(File.dirname(__FILE__), '../test_helper.rb')
# require 'test/model_stub'

class ActiveScaffold::DataStructures::Column
  def h(value)
    value
  end

  def format_column(value)
    value
  end
end

class VirtualColumnTest < Test::Unit::TestCase
  def setup
    @virtual_column = ActiveScaffold::DataStructures::Column.new(:fake, ModelStub)
  end

  def test_virtuality
    assert !@virtual_column.column
    assert !@virtual_column.association
    assert @virtual_column.virtual?
  end

  def test_sorting
    # right now, there's no intelligent sorting on virtual columns
    assert !@virtual_column.sortable?
  end

  def test_searching
    # right now, there's no intelligent searching on virtual columns
    assert !@virtual_column.searchable?
  end
end
