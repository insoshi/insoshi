require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe PeopleController do
  fixtures :people
  integrate_views

  it 'allows signup' do
    lambda do
      create_person
      response.should be_redirect      
    end.should change(Person, :count).by(1)
  end
  
  it 'requires password on signup' do
    lambda do
      create_person(:password => nil)
      assigns[:person].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(Person, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_person(:password_confirmation => nil)
      assigns[:person].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(Person, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_person(:email => nil)
      assigns[:person].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(Person, :count)
  end
  
  
  
  def create_person(options = {})
    post :create, :person => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end