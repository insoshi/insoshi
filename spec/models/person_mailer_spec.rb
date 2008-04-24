require File.dirname(__FILE__) + '/../spec_helper'

describe PersonMailer do
  
  before(:each) do
    @preferences = preferences(:one)
  end
  
  describe "password reminder" do
     before(:each) do
       @person = people(:quentin)
       @email = PersonMailer.create_password_reminder(@person)    
     end
   
     it "should have the right sender" do
       @email.from.first.should == "password-reminder@example.com"
     end
   
     it "should have the right recipient" do
       @email.to.first.should == @person.email
     end
   
     it "should have the unencrypted password in the body" do
       @email.body.should =~ /#{@person.unencrypted_password}/
     end
   end
   
   describe "message notification" do
     before(:each) do
       @message = people(:quentin).received_messages.first
       @email = PersonMailer.create_message_notification(@message)
     end
   
     it "should have the right sender" do
       @email.from.first.should == "message@example.com"
     end
   
     it "should have the right recipient" do
       @email.to.first.should == @message.recipient.email
     end

     it "should have the right domain in the body" do
        @email.body.should =~ /#{@preferences.domain}/
     end
   end
   
   describe "connection request" do
     
     before(:each) do
       @connection = Connection.request(people(:quentin), people(:aaron))
       @email = PersonMailer.create_connection_request(@connection)
       @person = @connection.person
     end
     
     it "should have the right recipient" do
       @email.to.first.should == @connection.contact.email
     end
     
     it "should have a URL to the contact" do
       url = "/connections/#{@connection.id}/edit"
       @email.body.should =~ /#{url}/
     end
   
     it "should have the right domain in the body" do
        @email.body.should =~ /#{@preferences.domain}/
     end
   end
   
   describe "email verification" do
     
     before(:each) do
       @ev = email_verifications(:one)
       @email = PersonMailer.create_email_verification(@ev)
     end
     
     it "should have the right recipient" do
       @email.to.first.should == @ev.person.email
     end
     
     it "should have a URL to the verification page" do
       url = "/people/verify/#{@ev.code}"
       @email.body.should =~ /#{url}/
     end

     it "should have the right server name in the body" do
       @email.body.should =~ /#{@preferences.server_name}/
     end
   end
end