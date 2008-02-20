require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  
  it "should render the new session page" do
    get :new
    response.should be_success
  end

  it 'logins and redirects' do
    post :create, :email => 'quentin@example.com', :password => 'test'
    session[:person_id].should_not be_nil
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    session[:person_id].should be_nil
    response.should be_success
  end

  it 'logs out' do
    login_as :quentin
    get :destroy
    session[:person_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    post :create, :email => 'quentin@example.com', :password => 'test', :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'does not remember me' do
    post :create, :email => 'quentin@example.com', :password => 'test', :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as :quentin
    get :destroy
    response.cookies["auth_token"].should == []
  end

  it 'logs in with cookie' do
    people(:quentin).remember_me
    request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'fails expired cookie login' do
    people(:quentin).remember_me
    people(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'fails cookie login' do
    people(:quentin).remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(person)
    auth_token people(person).remember_token
  end
end
