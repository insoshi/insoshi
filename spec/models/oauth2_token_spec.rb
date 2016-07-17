# == Schema Information
#
# Table name: oauth_tokens
#
#  id                    :integer          not null, primary key
#  person_id             :integer
#  type                  :string(20)
#  client_application_id :integer
#  token                 :string(50)
#  secret                :string(50)
#  authorized_at         :datetime
#  invalidated_at        :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  callback_url          :string(255)
#  verifier              :string(20)
#  scope                 :string(255)
#  expires_at            :datetime
#  group_id              :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Oauth2Token do
  fixtures :client_applications, :people, :oauth_tokens
  before(:each) do
    @token = Oauth2Token.create :client_application => client_applications(:one), :person=>people(:aaron)
  end
  
  it "should be valid" do
    @token.should be_valid
  end
  
  it "should have a token" do
    @token.token.should_not be_nil
  end
  
  it "should have a secret" do
    @token.secret.should_not be_nil
  end
  
  it "should be authorized" do
    @token.should be_authorized
  end
  
  it "should not be invalidated" do
    @token.should_not be_invalidated
  end

end
