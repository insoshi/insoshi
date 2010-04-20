require File.join(File.dirname(__FILE__), '../test_helper.rb')
# require 'test/model_stub'

class ClassWithFinder
  include ActiveScaffold::Finder
  def conditions_for_collection; end
  def conditions_from_params; end
  def conditions_from_constraints; end
  def joins_for_collection; end
  def custom_finder_options
    {}
  end
  def beginning_of_chain
    active_scaffold_config.model
  end
end

class FinderTest < Test::Unit::TestCase
  def setup
    @klass = ClassWithFinder.new
    @klass.stubs(:active_scaffold_config).returns(mock { stubs(:model).returns(ModelStub) })
    @klass.stubs(:active_scaffold_session_storage).returns({})
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
			'(LOWER("model_stubs"."a") LIKE ? OR LOWER("model_stubs"."b") LIKE ?) AND (LOWER("model_stubs"."a") LIKE ? OR LOWER("model_stubs"."b") LIKE ?)',
		  '%foo%', '%foo%', '%bar%', '%bar%'
		]
    assert_equal expected_conditions, ClassWithFinder.create_conditions_for_columns(tokens, columns)

    expected_conditions = [
      '(LOWER("model_stubs"."a") LIKE ? OR LOWER("model_stubs"."b") LIKE ?)',
      '%foo%', '%foo%'
    ]
    assert_equal expected_conditions, ClassWithFinder.create_conditions_for_columns('foo', columns)

    assert_equal nil, ClassWithFinder.create_conditions_for_columns('foo', [])
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

  def test_count_with_group
    @klass.expects(:custom_finder_options).returns({:group => :a})
    ModelStub.expects(:count).returns(ActiveSupport::OrderedHash['foo', 5])
    ModelStub.expects(:find).with(:all, has_entries(:limit => 20, :offset => 0))
    page = @klass.send :find_page, :per_page => 20, :pagination => true
    page.items
    
    assert_kind_of Integer, page.pager.count
    assert_equal 1, page.pager.count
    assert_nothing_raised { page.pager.number_of_pages }
  end

  def test_disabled_pagination
    ModelStub.expects(:count).returns(85)
    ModelStub.expects(:find).with(:all, Not(has_entries(:limit => 20, :offset => 0)))
    page = @klass.send :find_page, :per_page => 20, :pagination => false
    page.items
  end

  def test_infinite_pagination
    ModelStub.expects(:count).never
    page = @klass.send :find_page, :pagination => :infinite
  end
end
