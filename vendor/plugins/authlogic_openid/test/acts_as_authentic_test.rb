require File.dirname(__FILE__) + '/test_helper.rb'

class ActsAsAuthenticTest < ActiveSupport::TestCase
  def test_included
    assert User.send(:acts_as_authentic_modules).include?(AuthlogicOpenid::ActsAsAuthentic::Methods)
    assert_equal :validate_password_with_openid?, User.validates_length_of_password_field_options[:if]
    assert_equal :validate_password_with_openid?, User.validates_confirmation_of_password_field_options[:if]
    assert_equal :validate_password_with_openid?, User.validates_length_of_password_confirmation_field_options[:if]
  end
  
  def test_password_not_required_on_create
    user = User.new
    user.login = "sweet"
    user.email = "a@a.com"
    user.openid_identifier = "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"
    assert !user.save {} # because we are redirecting, the user was NOT saved
    assert_redirecting_to_yahoo "for_model"
  end
  
  def test_password_required_on_create
    user = User.new
    user.login = "sweet"
    user.email = "a@a.com"
    assert !user.save
    assert user.errors.on(:password)
    assert user.errors.on(:password_confirmation)
  end
  
  def test_password_not_required_on_update
    ben = users(:ben)
    assert_nil ben.crypted_password
    assert ben.save
  end
  
  def test_password_required_on_update
    ben = users(:ben)
    ben.openid_identifier = nil
    assert_nil ben.crypted_password
    assert !ben.save
    assert ben.errors.on(:password)
    assert ben.errors.on(:password_confirmation)
  end
  
  def test_validates_uniqueness_of_openid_identifier
    u = User.new(:openid_identifier => "bens_identifier")
    assert !u.valid?
    assert u.errors.on(:openid_identifier)
  end
  
  def test_setting_openid_identifier_changed_persistence_token
    ben = users(:ben)
    old_persistence_token = ben.persistence_token
    ben.openid_identifier = "http://new"
    assert_not_equal old_persistence_token, ben.persistence_token
  end
  
  def test_invalid_openid_identifier
    u = User.new(:openid_identifier => "%")
    assert !u.valid?
    assert u.errors.on(:openid_identifier)
  end
  
  def test_blank_openid_identifer_gets_set_to_nil
    u = User.new(:openid_identifier => "")
    assert_nil u.openid_identifier
  end
  
  def test_updating_with_openid
    ben = users(:ben)
    ben.openid_identifier = "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"
    assert !ben.save {} # because we are redirecting
    assert_redirecting_to_yahoo "for_model"
  end
  
  def test_updating_without_openid
    ben = users(:ben)
    ben.openid_identifier = nil
    ben.password = "test"
    ben.password_confirmation = "test"
    assert ben.save
    assert_not_redirecting
  end
  
  def test_updating_without_validation
    ben = users(:ben)
    ben.openid_identifier = "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"
    assert ben.save(false)
    assert_not_redirecting
  end
  
  def test_updating_without_a_block
    ben = users(:ben)
    ben.openid_identifier = "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"
    assert ben.save
    ben.reload
    assert_equal "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--", ben.openid_identifier
  end
  
  def test_updating_while_not_activated
    UserSession.controller = nil
    ben = users(:ben)
    ben.openid_identifier = "https://me.yahoo.com/a/9W0FJjRj0o981TMSs0vqVxPdmMUVOQ--"
    assert ben.save {}
  end
end