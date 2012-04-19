require File.dirname(__FILE__) + '/../spec_helper'

describe Oauth2Verifier do
  fixtures :client_applications, :users, :oauth_tokens
  before(:each) do
    @verifier = Oauth2Verifier.create :client_application => client_applications(:one), :user=>users(:aaron), :scope => "bbbb aaaa"
  end

  it "should be valid" do
    @verifier.should be_valid
  end

  it "should have a code" do
    @verifier.code.should_not be_nil
  end

  it "should not have a secret" do
    @verifier.secret.should be_nil
  end

  it "should be authorized" do
    @verifier.should be_authorized
  end

  it "should not be invalidated" do
    @verifier.should_not be_invalidated
  end

  it "should generate query string" do
    @verifier.to_query.should == "code=#{@verifier.code}"
    @verifier.state="bbbb aaaa"
    @verifier.to_query.should == "code=#{@verifier.code}&state=bbbb%20aaaa"
  end

  it "should properly exchange for token" do
    @token = @verifier.exchange!
    @verifier.should be_invalidated
    @token.user.should==@verifier.user
    @token.client_application.should == @verifier.client_application
    @token.should be_authorized
    @token.should_not be_invalidated
    @token.scope.should == @verifier.scope
  end
end