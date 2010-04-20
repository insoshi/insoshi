require File.join(File.dirname(__FILE__), '../test_helper.rb')

class Config::ShowTest < Test::Unit::TestCase
  def setup
    @config = ActiveScaffold::Config::Core.new :model_stub
    @default_link = @config.show.link
  end
  
  def teardown
    @config.show.link = @default_link
  end
  
  def test_default_options
    assert_equal 'Show Modelstub', @config.show.label
  end

  def test_link_defaults
    link = @config.show.link
    assert !link.page?
    assert !link.popup?
    assert !link.confirm?
    assert_equal "show", link.action
    assert_equal "Show", link.label
    assert link.inline?
    blank = {}
    assert_equal blank, link.html_options
    assert_equal :get, link.method
    assert_equal :member, link.type
    assert_equal :read, link.crud_type
    assert_equal :show_authorized?, link.security_method
  end
  
  def test_setting_link
    @config.show.link = ActiveScaffold::DataStructures::ActionLink.new('update', :label => 'Monkeys')
    assert_not_equal(@default_link, @config.show.link)
  end
  
  def test_label
    label = 'create new monkeys'
    @config.show.label = label
    assert_equal label, @config.show.label
  end
end
