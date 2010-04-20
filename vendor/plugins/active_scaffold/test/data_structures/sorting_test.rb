require File.join(File.dirname(__FILE__), '../test_helper.rb')
# require 'test/model_stub'

class SortingTest < Test::Unit::TestCase
  def setup
    @columns = ActiveScaffold::DataStructures::Columns.new(ModelStub, :a, :b, :c, :d)
    @sorting = ActiveScaffold::DataStructures::Sorting.new(@columns)
  end

  def test_add
    @sorting.add :a, 'ASC'
    # test adding by symbol
    assert @sorting.sorts_on?(:a)
    # test adding an uppercase string direction
    assert_equal 'ASC', @sorting.direction_of(:a)

    @sorting.add 'b', :ASC
    # test adding by string
    assert @sorting.sorts_on?(:b)
    # test adding an uppercase symbol direction
    assert_equal 'ASC', @sorting.direction_of(:b)

    @sorting.add @columns[:c], 'desc'
    # test adding by object
    assert @sorting.sorts_on?(:c)
    # test adding a lowercase string direction
    assert_equal 'DESC', @sorting.direction_of(:c)

    @sorting << [:d, :desc]
    # testing adding with the alias
    assert @sorting.sorts_on?(:d)
    assert_equal 'DESC', @sorting.direction_of(:d)

    @sorting.clear

    # test adding without a direction (test default)
    @sorting.add :a
    assert_equal 'ASC', @sorting.direction_of(:a)

    # test adding a bad column
    assert_raises ArgumentError do
      @sorting.add :foo
    end

    # test adding a bad direction
    assert_raises ArgumentError do
      @sorting.add :b, :FOO
    end
  end

  def test_set
    @sorting.add :a, 'ASC'
    assert @sorting.sorts_on?(:a)

    @sorting.set :b, 'DESC'
    assert @sorting.instance_variable_get('@clauses').size == 1
    assert !@sorting.sorts_on?(:a)
    assert @sorting.sorts_on?(:b)
    assert_equal 'DESC', @sorting.direction_of(:b)
  end

  def test_sorts_on
    @sorting.add :a
    @sorting.add :b

    assert @sorting.sorts_on?(:a)
    assert @sorting.sorts_on?(:b)
    assert !@sorting.sorts_on?(:c)
  end

  def test_direction_of
    @sorting.add :a, 'ASC'
    @sorting.add :b, :DESC

    assert_equal 'ASC', @sorting.direction_of(:a)
    assert_equal 'DESC', @sorting.direction_of(:b)
  end

  def test_sorts_by_method
    @columns[:a].sort_by :method => proc{0}

    #test pure method sorting: true
    @sorting.add :a
    assert @sorting.sorts_by_method?

    #test mixed sql/method sorting: raise error
    assert_raise ArgumentError do
      @sorting.add :b
    end
    
    #test pure sql sorting: false
    @sorting.clear
    @sorting.add :b
    assert !@sorting.sorts_by_method?
  end

  def test_build_order_clause
    assert @sorting.clause.nil?

    @sorting << [:a, 'desc']
    @sorting << [:b, 'asc']

    assert_equal '"model_stubs"."a" DESC, "model_stubs"."b" ASC', @sorting.clause
  end
  
  def test_set_default_sorting_with_simple_default_scope
    model_stub_with_default_scope = ModelStub.clone
    model_stub_with_default_scope.class_eval { default_scope :order => 'a' }
    @sorting.set_default_sorting model_stub_with_default_scope
    
    assert @sorting.sorts_on?(:a)
    assert_equal 'ASC', @sorting.direction_of(:a)
    assert_nil @sorting.clause
  end

  def test_set_default_sorting_with_complex_default_scope
    model_stub_with_default_scope = ModelStub.clone
    model_stub_with_default_scope.class_eval { default_scope :order => 'a DESC, players.last_name ASC' }
    @sorting.set_default_sorting model_stub_with_default_scope
    
    assert @sorting.sorts_on?(:a)
    assert_equal 'DESC', @sorting.direction_of(:a)
    assert_equal 1, @sorting.instance_variable_get(:@clauses).size
    assert_nil @sorting.clause
  end
end
