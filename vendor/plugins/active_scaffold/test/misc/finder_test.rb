require File.join(File.dirname(__FILE__), '../test_helper.rb')
# require 'test/model_stub'

class ClassWithFinder
  include ActiveScaffold::Finder
end

class FinderTest < Test::Unit::TestCase
  def setup
    @klass = ClassWithFinder.new
  end

  def test_create_conditions_for_columns
    columns = [
      ActiveScaffold::DataStructures::Column.new(:a, ModelStub),
      ActiveScaffold::DataStructures::Column.new(:b, ModelStub)
    ]
    tokens = [
      'foo',
      'bar'
    ]

    expected_conditions = [
			'(LOWER(model_stubs.a) LIKE ? OR LOWER(model_stubs.b) LIKE ?) AND (LOWER(model_stubs.a) LIKE ? OR LOWER(model_stubs.b) LIKE ?)',
		  '%foo%', '%foo%', '%bar%', '%bar%'
		]
    assert_equal expected_conditions, ActiveScaffold::Finder.create_conditions_for_columns(tokens, columns)

    expected_conditions = [
      '(LOWER(model_stubs.a) LIKE ? OR LOWER(model_stubs.b) LIKE ?)',
      '%foo%', '%foo%'
    ]
    assert_equal expected_conditions, ActiveScaffold::Finder.create_conditions_for_columns('foo', columns)

    assert_equal nil, ActiveScaffold::Finder.create_conditions_for_columns('foo', [])
  end

  def test_build_order_clause
    columns = ActiveScaffold::DataStructures::Columns.new(ModelStub, :a, :b, :c, :d)
    sorting = ActiveScaffold::DataStructures::Sorting.new(columns)

    assert @klass.send(:build_order_clause, nil).nil?
    assert @klass.send(:build_order_clause, sorting).nil?

    sorting << [:a, 'desc']
    sorting << [:b, 'asc']

    assert_equal 'model_stubs.a DESC, model_stubs.b ASC', @klass.send(:build_order_clause, sorting)
  end

  def test_method_sorting
    column = ActiveScaffold::DataStructures::Column.new('a', ModelStub)
    column.sort_by :method => proc{self}

    collection = [16000, 2853, 98765, 6188, 4]
    assert_equal collection.sort, @klass.send(:sort_collection_by_column, collection, column, 'asc')
    assert_equal collection.sort.reverse, @klass.send(:sort_collection_by_column, collection, column, 'desc')

    collection = ['a', nil, 'b']
    result = nil
    assert_nothing_raised do
      result = @klass.send(:sort_collection_by_column, collection, column, 'asc')
    end
    assert_equal [nil, 'a', 'b'], result

    column.sort_by :method => 'self'
    collection = [3, 1, 2]
    assert_equal collection.sort, @klass.send(:sort_collection_by_column, collection, column, 'asc')
  end
end