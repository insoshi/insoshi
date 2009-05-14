require File.join(File.dirname(__FILE__), '../test_helper.rb')
# require 'test/model_stub'

class AssociationColumnTest < Test::Unit::TestCase
  def setup
    @association_column = ActiveScaffold::DataStructures::Column.new('other_model', ModelStub)
  end

  def test_virtuality
    assert @association_column.association
    assert !@association_column.virtual?
  end

  def test_sorting
    # sorting on association columns is method-based
    hash = {:method => "other_model.to_s"}
    assert_equal hash, @association_column.sort
  end

  def test_searching
    # right now, there's no intelligent searching on association columns
    assert !@association_column.searchable?
  end

  def test_association
    assert @association_column.association.is_a?(ActiveRecord::Reflection::AssociationReflection)
  end

  def test_includes
    assert_equal [:other_model], @association_column.includes
  end

  def test_plurality
    assert @association_column.singular_association?
    assert !@association_column.plural_association?

    plural_association_column = ActiveScaffold::DataStructures::Column.new('other_models', ModelStub)
    assert plural_association_column.plural_association?
    assert !plural_association_column.singular_association?
  end
end
