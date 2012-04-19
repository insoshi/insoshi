require 'spec_helper'
require 'multi_json'
require 'oauth/provider/authorizer'
require 'dummy_provider_models'

describe OAuth::Provider::Authorizer do


  describe "Authorization code" do

    describe "should issue code" do

      before(:each) do
        @user = double("user")
        @app  = double("app")
        @code = double("code", :token => "secret auth code")

        ::ClientApplication.should_receive(:find_by_key!).with('client id').and_return(@app)
      end

      it "should allow" do
        ::Oauth2Verifier.should_receive(:create!).with( :client_application=>@app,
                                                  :user=>@user,
                                                  :callback_url=>'http://mysite.com/callback',
                                                  :scope => 'a b').and_return(@code)

        @authorizer = OAuth::Provider::Authorizer.new @user, true, :response_type => 'code',
                                                      :scope => "a b",
                                                      :client_id => 'client id',
                                                      :redirect_uri => 'http://mysite.com/callback'

        @authorizer.redirect_uri.should == "http://mysite.com/callback?code=secret%20auth%20code"
        @authorizer.should be_authorized

      end

      it "should include state" do
        ::Oauth2Verifier.should_receive(:create!).with( :client_application=>@app,
                                                  :user=>@user,
                                                  :callback_url=>'http://mysite.com/callback',
                                                  :scope => 'a b').and_return(@code)

        @authorizer = OAuth::Provider::Authorizer.new @user, true, :response_type => 'code',
                                                      :state => 'customer id',
                                                      :scope => "a b",
                                                      :client_id => 'client id',
                                                      :redirect_uri => 'http://mysite.com/callback'

        @authorizer.redirect_uri.should == "http://mysite.com/callback?code=secret%20auth%20code&state=customer%20id"
        @authorizer.should be_authorized

      end

      it "should allow query string in callback" do
        ::Oauth2Verifier.should_receive(:create!).with( :client_application=>@app,
                                                  :user=>@user,
                                                  :callback_url=>'http://mysite.com/callback?this=one',
                                                  :scope => 'a b').and_return(@code)

        @authorizer = OAuth::Provider::Authorizer.new @user, true, :response_type => 'code',
                                                      :scope => "a b",
                                                      :client_id => 'client id',
                                                      :redirect_uri => 'http://mysite.com/callback?this=one'
        @authorizer.should be_authorized
        @authorizer.redirect_uri.should == "http://mysite.com/callback?this=one&code=secret%20auth%20code"
      end
    end


  end

  describe "user does not authorize" do

    it "should send error" do
      @authorizer = OAuth::Provider::Authorizer.new @user, false, :response_type => 'code',
                                                    :scope => "a b",
                                                    :client_id => 'client id',
                                                    :redirect_uri => 'http://mysite.com/callback'

      @authorizer.redirect_uri.should == "http://mysite.com/callback?error=access_denied"
      @authorizer.should_not be_authorized

    end

    it "should send error with state and query params in callback" do
      @authorizer = OAuth::Provider::Authorizer.new @user, false, :response_type => 'code',
                                                    :scope => "a b",
                                                    :client_id => 'client id',
                                                    :redirect_uri=>'http://mysite.com/callback?this=one',
                                                    :state => "my customer"

      @authorizer.redirect_uri.should == "http://mysite.com/callback?this=one&error=access_denied&state=my%20customer"
      @authorizer.should_not be_authorized

    end

  end

  describe "Implict Grant" do

    describe "should issue token" do

      before(:each) do
        @user = double("user")
        @app  = double("app")
        @token = double("token", :token => "secret auth code")

        ::ClientApplication.should_receive(:find_by_key!).with('client id').and_return(@app)
      end

      it "should allow" do
        ::Oauth2Token.should_receive(:create!).with( :client_application=>@app,
                                                  :user=>@user,
                                                  :callback_url=>'http://mysite.com/callback',
                                                  :scope => 'a b').and_return(@token)

        @authorizer = OAuth::Provider::Authorizer.new @user, true, :response_type => 'token',
                                                      :scope => "a b",
                                                      :client_id => 'client id',
                                                      :redirect_uri => 'http://mysite.com/callback'

        @authorizer.redirect_uri.should == "http://mysite.com/callback#access_token=secret%20auth%20code"
        @authorizer.should be_authorized

      end

      it "should include state" do
        ::Oauth2Token.should_receive(:create!).with( :client_application=>@app,
                                                  :user=>@user,
                                                  :callback_url=>'http://mysite.com/callback',
                                                  :scope => 'a b').and_return(@token)

        @authorizer = OAuth::Provider::Authorizer.new @user, true, :response_type => 'token',
                                                      :state => 'customer id',
                                                      :scope => "a b",
                                                      :client_id => 'client id',
                                                      :redirect_uri => 'http://mysite.com/callback'

        @authorizer.redirect_uri.should == "http://mysite.com/callback#access_token=secret%20auth%20code&state=customer%20id"
        @authorizer.should be_authorized

      end

      it "should allow query string in callback" do
        ::Oauth2Token.should_receive(:create!).with( :client_application=>@app,
                                                  :user=>@user,
                                                  :callback_url=>'http://mysite.com/callback?this=one',
                                                  :scope => 'a b').and_return(@token)

        @authorizer = OAuth::Provider::Authorizer.new @user, true, :response_type => 'token',
                                                      :scope => "a b",
                                                      :client_id => 'client id',
                                                      :redirect_uri => 'http://mysite.com/callback?this=one'
        @authorizer.should be_authorized
        @authorizer.redirect_uri.should == "http://mysite.com/callback?this=one#access_token=secret%20auth%20code"
      end
    end


  end

  describe "user does not authorize" do

    it "should send error" do
      @authorizer = OAuth::Provider::Authorizer.new @user, false, :response_type => 'token',
                                                    :scope => "a b",
                                                    :client_id => 'client id',
                                                    :redirect_uri => 'http://mysite.com/callback'

      @authorizer.redirect_uri.should == "http://mysite.com/callback#error=access_denied"
      @authorizer.should_not be_authorized

    end

    it "should send error with state and query params in callback" do
      @authorizer = OAuth::Provider::Authorizer.new @user, false, :response_type => 'token',
                                                    :scope => "a b",
                                                    :client_id => 'client id',
                                                    :redirect_uri=>'http://mysite.com/callback?this=one',
                                                    :state => "my customer"

      @authorizer.redirect_uri.should == "http://mysite.com/callback?this=one#error=access_denied&state=my%20customer"
      @authorizer.should_not be_authorized

    end

  end

  it "should handle unsupported response type" do
    @user = double("user")

    @authorizer = OAuth::Provider::Authorizer.new @user, false, :response_type => 'my new',
                                                  :scope => "a b",
                                                  :client_id => 'client id',
                                                  :redirect_uri => 'http://mysite.com/callback'

    @authorizer.redirect_uri.should == "http://mysite.com/callback#error=unsupported_response_type"
    @authorizer.should_not be_authorized

  end

end