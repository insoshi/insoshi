require File.dirname(__FILE__) + '/test_helper.rb'

class SessionTest < ActiveSupport::TestCase
  def test_openid_identifier
    session = UserSession.new
    assert session.respond_to?(:openid_identifier)
    session.openid_identifier = "http://test"
    assert_equal "http://test/", session.openid_identifier
  end
  
  def test_validate_openid_error
    session = UserSession.new
    session.openid_identifier = "yes"
    session.openid_identifier = "%"
    assert_nil session.openid_identifier
    assert !session.save
    assert session.errors.on(:openid_identifier)
  end
  
  def test_validate_by_nil_openid_identifier
    session = UserSession.new
    assert !session.save
    assert_not_redirecting
  end
  
  def test_validate_by_correct_openid_identifier
    session = UserSession.new
    session.openid_identifier = "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"
    assert !session.save
    assert_redirecting_to_yahoo "for_session"
  end
end