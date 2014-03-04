require File.dirname(__FILE__) + '/../spec_helper'

describe PersonMailer do

  before(:each) do
    @preferences = preferences(:one)
    @mailer = PersonMailer
    @server = @mailer.server
    @domain = @mailer.domain
  end

   pending "message notification" do
     before(:each) do
       @message = people(:quentin).received_messages.first
       @email = PersonMailer.message_notification(@message)
     end

     it "should have the right sender" do
       @email.from.first.should == "message@#{@domain}"
     end

     it "should have the right recipient" do
       @email.to.first.should == @message.recipient.email
     end

     it "should have the right domain in the body" do
        @email.body.should =~ /#{@server}/
     end
   end

   pending "connection request" do

     before(:each) do
       @person  = people(:quentin)
       @contact = people(:aaron)
       Connection.request(@person, @contact)
       @connection = Connection.conn(@contact, @person)
       @email = PersonMailer.connection_request(@connection)
     end

     it "should have the right recipient" do
       @email.to.first.should == @contact.email
     end

     it "should have the right requester" do
       @email.body.should =~ /#{@person.name}/
     end

     it "should have a URL to the connection" do
       url = "http://#{@server}/connections/#{@connection.id}/edit"
       @email.body.should =~ /#{url}/
     end

     it "should have the right domain in the body" do
        @email.body.should =~ /#{@server}/
     end

     it "should have a link to the recipient's preferences" do
       prefs_url = "http://#{@server}"
       prefs_url += "/people/#{@contact.to_param}/edit"
       @email.body.should =~ /#{prefs_url}/
     end
   end

end
