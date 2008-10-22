require 'test_helper'

class ListingsMailerTest < ActionMailer::TestCase
  tests ListingsMailer
  def test_updates
    @expected.subject = 'ListingsMailer#updates'
    @expected.body    = read_fixture('updates')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ListingsMailer.create_updates(@expected.date).encoded
  end

end
