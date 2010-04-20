require File.join(File.dirname(__FILE__), '../test_helper.rb')

class FormColumnHelpersTest < ActionView::TestCase
  include ActiveScaffold::Helpers::FormColumnHelpers

  def setup
    @column = ActiveScaffold::DataStructures::Column.new(:a, ModelStub)
    @record = stub(:a => nil)
  end

  def test_choices_for_select_form_ui_for_simple_column
    @column.options[:options] = [:value_1, :value_2, :value_3]
    assert_dom_equal '<select name="record[a]" id="record_a"><option value="value_1">Value 1</option><option value="value_2">Value 2</option><option value="value_3">Value 3</option></select>', active_scaffold_input_select(@column, {})

    @column.options[:options] = %w(value_1 value_2 value_3)
    assert_dom_equal '<select name="record[a]" id="record_a"><option value="value_1">value_1</option><option value="value_2">value_2</option><option value="value_3">value_3</option></select>', active_scaffold_input_select(@column, {})

    @column.options[:options] = [%w(text_1 value_1), %w(text_2 value_2), %w(text_3 value_3)]
    assert_dom_equal '<select name="record[a]" id="record_a"><option value="value_1">text_1</option><option value="value_2">text_2</option><option value="value_3">text_3</option></select>', active_scaffold_input_select(@column, {})

    @column.options[:options] = [[:text_1, :value_1], [:text_2, :value_2], [:text_3, :value_3]]
    assert_dom_equal '<select name="record[a]" id="record_a"><option value="value_1">Text 1</option><option value="value_2">Text 2</option><option value="value_3">Text 3</option></select>', active_scaffold_input_select(@column, {})
  end

  def test_options_for_select_form_ui_for_simple_column
    @column.options = {:include_blank => 'None', :selected => 'value_2', :disabled => %w(value_1 value_3)}
    @column.options[:options] = %w(value_1 value_2 value_3)
    @column.options[:html_options] = {:class => 'big'}
    assert_dom_equal '<select name="record[a]" class="big" id="record_a"><option value="">None</option><option disabled="disabled" value="value_1">value_1</option><option selected="selected" value="value_2">value_2</option><option disabled="disabled" value="value_3">value_3</option></select>', active_scaffold_input_select(@column, {})
  end
end
