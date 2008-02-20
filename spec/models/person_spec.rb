require File.dirname(__FILE__) + '/../spec_helper'

describe Person do

  before(:each) do
    @person = people(:quentin)
  end

  describe "attributes" do
    it "should be valid" do
      create_person.should be_valid
    end
  
    it 'requires password' do
      u = create_person(:password => nil)
      u.errors.on(:password).should_not be_nil
    end

    it 'requires password confirmation' do
      u = create_person(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end

    it 'requires email' do
      u = create_person(:email => nil)
      u.errors.on(:email).should_not be_nil
    end
  end

  it 'resets password' do
    @person.update_attributes(:password => 'newp',
                              :password_confirmation => 'newp')
    Person.authenticate('quentin@example.com', 'newp').should == @person
  end

  it 'does not rehash password' do
    @person.update_attributes(:email => 'quentin2@example.com')
    Person.authenticate('quentin2@example.com', 'test').should == @person
  end

  it 'authenticates person' do
    Person.authenticate('quentin@example.com', 'test').should == @person
  end
  
  it "should authenticate case-insensitively" do
    Person.authenticate('queNTin@eXample.com', 'test').should == @person    
  end

  it 'sets remember token' do
    @person.remember_me
    @person.remember_token.should_not be_nil
    @person.remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    @person.remember_me
    @person.remember_token.should_not be_nil
    @person.forget_me
    @person.remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    @person.remember_me_for 1.week
    after = 1.week.from_now.utc
    @person.remember_token.should_not be_nil
    @person.remember_token_expires_at.should_not be_nil
    @person.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    @person.remember_me_until time
    @person.remember_token.should_not be_nil
    @person.remember_token_expires_at.should_not be_nil
    @person.remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    @person.remember_me
    after = 2.weeks.from_now.utc
    @person.remember_token.should_not be_nil
    @person.remember_token_expires_at.should_not be_nil
    @person.remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_person(options = {})
    record = Person.new({ :email => 'quire@example.com',
                          :password => 'quire',
                          :password_confirmation => 'quire',
                          :name => 'Quire',
                          :description => 'A new person' }.merge(options))
    record.valid?
    record
  end
end
