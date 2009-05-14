require File.join(File.dirname(__FILE__), '../test_helper.rb')

class LocalizationTest < Test::Unit::TestCase

  def test_localization
    ##
    ## test no language specified
    ##
    assert_equal "dutch", as_("dutch")
    assert_equal "Create 2", as_("Create %d", 2)
  end
end