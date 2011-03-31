require File.dirname(__FILE__) + '/../spec_helper'

describe RequestToken do
  fixtures :client_applications,:people,:oauth_tokens
  before(:each) do
    @token = RequestToken.create :client_application=>client_applications(:one)
  end

  it "should be valid" do
    @token.should be_valid
  end
  
  it "should not have errors" do
    @token.errors.should_not==[]
  end
  
  it "should have a token" do
    @token.token.should_not be_nil
  end

  it "should have a secret" do
    @token.secret.should_not be_nil
  end
  
  it "should not be authorized" do 
    @token.should_not be_authorized
  end

  it "should not be invalidated" do
    @token.should_not be_invalidated
  end
  
  it "should authorize request" do
    @token.authorize!(people(:quentin))
    @token.should be_authorized
    @token.authorized_at.should_not be_nil
    @token.person.should==people(:quentin)
  end
  
  it "should not exchange without approval" do
    @token.exchange!.should==false
    @token.should_not be_invalidated
  end
  
  it "should not exchange without approval" do
    pending
    @token.authorize!(people(:quentin))
    @access=@token.exchange!
    @access.should_not==false
    @token.should be_invalidated
   
    @access.person.should==people(:quentin)
    @access.should be_authorized
  end
  
end
