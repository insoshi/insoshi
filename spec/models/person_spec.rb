require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Person do
  fixtures :people

  describe 'being created' do
    before do
      @person = nil
      @creating_person = lambda do
        @person = create_person
        violated "#{@person.errors.full_messages.to_sentence}" if @person.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_person.should change(Person, :count).by(1)
    end
  end
  
  it 'requires password' do
    lambda do
      u = create_person(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(Person, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_person(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(Person, :count)
  end

  it 'requires email' do
    lambda do
      u = create_person(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(Person, :count)
  end

  it 'resets password' do
    people(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Person.authenticate('quentin@example.com', 'new password').should == people(:quentin)
  end

  it 'does not rehash password' do
    people(:quentin).update_attributes(:email => 'quentin2@example.com')
    Person.authenticate('quentin2@example.com', 'test').should == people(:quentin)
  end

  it 'authenticates person' do
    Person.authenticate('queNTin@eXample.com', 'test').should == people(:quentin)
  end

  it 'sets remember token' do
    people(:quentin).remember_me
    people(:quentin).remember_token.should_not be_nil
    people(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    people(:quentin).remember_me
    people(:quentin).remember_token.should_not be_nil
    people(:quentin).forget_me
    people(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    people(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    people(:quentin).remember_token.should_not be_nil
    people(:quentin).remember_token_expires_at.should_not be_nil
    people(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    people(:quentin).remember_me_until time
    people(:quentin).remember_token.should_not be_nil
    people(:quentin).remember_token_expires_at.should_not be_nil
    people(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    people(:quentin).remember_me
    after = 2.weeks.from_now.utc
    people(:quentin).remember_token.should_not be_nil
    people(:quentin).remember_token_expires_at.should_not be_nil
    people(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_person(options = {})
    record = Person.new({ :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
