require File.join(File.dirname(__FILE__), '../test_helper.rb')

class LocalizationTest < Test::Unit::TestCase

  def test_localization
    ##
    ## test no language specified
    ##
    assert_equal "Dutch", as_(:dutch)
    assert_equal "Create Test", as_(:create_model, :model => 'Test')
  end
end
