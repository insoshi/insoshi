# == Schema Information
#
# Table name: client_applications
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  url          :string(255)
#  support_url  :string(255)
#  callback_url :string(255)
#  key          :string(50)
#  secret       :string(50)
#  person_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  description  :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'
describe ClientApplication do 
  fixtures :people, :client_applications, :oauth_tokens
  before(:each) do
    @application = ClientApplication.create :name => "Agree2", :url => "http://agree2.com", :person => people(:quentin)
  end

  it "should be valid" do
    @application.should be_valid
  end
  
    
  it "should not have errors" do
    @application.errors.full_messages.should == []
  end
  
  it "should have key and secret" do
    @application.key.should_not be_nil
    @application.secret.should_not be_nil
  end

  it "should have credentials" do
    @application.credentials.should_not be_nil
    @application.credentials.key.should == @application.key
    @application.credentials.secret.should == @application.secret
  end
  
end

