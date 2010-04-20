require File.join(File.dirname(__FILE__), '../test_helper.rb')

class Config::ListTest < Test::Unit::TestCase
  def setup
    @config = ActiveScaffold::Config::Core.new :model_stub
  end

  def test_default_options
    assert_equal 15, @config.list.per_page
    assert_equal '-', @config.list.empty_field_text
    assert @config.actions.include?(:search)
    assert_equal 'search', @config.list.search_partial
    assert_equal :no_entries, @config.list.no_entries_message
    assert_equal :filtered, @config.list.filtered_message
    assert !@config.list.always_show_create
    assert !@config.list.always_show_search
  end
  
  def test_no_entries
    @config.list.no_entries_message = 'No items'
    assert_equal 'No items', @config.list.no_entries_message
  end
  
  def test_filtered_message
    @config.list.filtered_message = 'filtered items'
    assert_equal 'filtered items', @config.list.filtered_message
  end
  
  def test_per_page
    per_page = 35
    @config.list.per_page = per_page
    assert_equal per_page, @config.list.per_page
  end
  
  def test_always_show_create
    always_show_create = true
    @config.list.always_show_create = always_show_create
    assert_equal always_show_create, @config.list.always_show_create
  end
  
  def test_always_show_create_when_create_is_not_enabled
    always_show_create = true
    @config.list.always_show_create = always_show_create
    @config.actions.exclude :create
    assert_equal false, @config.list.always_show_create
  end
  
  def test_always_show_search
    @config.list.always_show_search = true
    assert @config.list.always_show_search
    assert_equal 'search', @config.list.search_partial
  end
  
  def test_always_show_search_when_search_is_not_enabled
    @config.list.always_show_search = true
    @config.actions.exclude :search
    assert_equal false, @config.list.always_show_search
  end

  def test_always_show_search_when_field_search
    @config.list.always_show_search = true
    @config.actions.swap :search, :live_search
    assert @config.list.always_show_search
    assert_equal 'live_search', @config.list.search_partial
  end
  
  def test_always_show_search_when_field_search
    @config.list.always_show_search = true
    @config.actions.swap :search, :field_search
    assert @config.list.always_show_search
    assert_equal 'field_search', @config.list.search_partial
  end

end
