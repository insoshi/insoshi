require 'test_helper'

class BroadcastMailerTest < ActionMailer::TestCase
  tests BroadcastMailer
  def test_spew
    @expected.subject = 'BroadcastMailer#spew'
    @expected.body    = read_fixture('spew')
    @expected.date    = Time.now

    assert_equal @expected.encoded, BroadcastMailer.create_spew(@expected.date).encoded
  end

end
