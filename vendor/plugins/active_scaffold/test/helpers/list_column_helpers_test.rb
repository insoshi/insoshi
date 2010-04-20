require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ListColumnHelpersTest < ActionView::TestCase
  include ActiveScaffold::Helpers::ListColumnHelpers
  include ActiveScaffold::Helpers::ViewHelpers

  def setup
    @column = ActiveScaffold::DataStructures::Column.new(:a, ModelStub)
    @record = stub(:a => 'value_2')
    @config = stub(:list => stub(:empty_field_text => '-'))
  end

  def test_options_for_select_list_ui_for_simple_column
    @column.options[:options] = [:value_1, :value_2, :value_3]
    assert_equal 'Value 2', active_scaffold_column_select(@column, @record)

    @column.options[:options] = %w(value_1 value_2 value_3)
    assert_equal 'value_2', active_scaffold_column_select(@column, @record)

    @column.options[:options] = [%w(text_1 value_1), %w(text_2 value_2), %w(text_3 value_3)]
    assert_equal 'text_2', active_scaffold_column_select(@column, @record)

    @column.options[:options] = [[:text_1, :value_1], [:text_2, :value_2], [:text_3, :value_3]]
    assert_equal 'Text 2', active_scaffold_column_select(@column, @record)
  end

  private
  def active_scaffold_config
    @config
  end
end
