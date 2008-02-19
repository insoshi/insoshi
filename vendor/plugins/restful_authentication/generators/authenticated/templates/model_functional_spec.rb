require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe <%= model_controller_class_name %>Controller do
  fixtures :<%= table_name %>

  it 'allows signup' do
    lambda do
      create_<%= file_name %>
      response.should be_redirect      
    end.should change(<%= class_name %>, :count).by(1)
  end

  <% if options[:stateful] %>
  it 'signs up user in pending state' do
    create_user
    assigns(:user).should be_pending
  end<% end %>

  <% if options[:include_activation] %>
  it 'signs up user with activation code' do
    create_user
    assigns(:user).activation_code.should_not be_nil
  end<% end %>

  it 'requires login on signup' do
    lambda do
      create_<%= file_name %>(:login => nil)
      assigns[:<%= file_name %>].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(<%= class_name %>, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_<%= file_name %>(:password => nil)
      assigns[:<%= file_name %>].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(<%= class_name %>, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_<%= file_name %>(:password_confirmation => nil)
      assigns[:<%= file_name %>].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(<%= class_name %>, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_<%= file_name %>(:email => nil)
      assigns[:<%= file_name %>].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(<%= class_name %>, :count)
  end
  
  <% if options[:include_activation] %>
  it 'activates user' do
    <%= class_name %>.authenticate('aaron', 'test').should be_nil
    get :activate, :activation_code => <%= table_name %>(:aaron).activation_code
    response.should redirect_to('/')
    flash[:notice].should_not be_nil
    <%= class_name %>.authenticate('aaron', 'test').should == <%= table_name %>(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should be_nil
  end<% end %>
  
  def create_<%= file_name %>(options = {})
    post :create, :<%= file_name %> => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end