require File.dirname(__FILE__) + '/../spec_helper'

describe ConnectionsController do
  integrate_views
  
  before(:each) do
    @person = login_as(:quentin)
    @contact = people(:aaron)
  end
  
  it "should protect the create page" do
    logout
    post :create
    response.should redirect_to(login_url)
  end
  
  it "should create a new connection request" do
    Connection.should_receive(:request).with(@person, @contact).
      and_return(true)
    post :create, :person_id => @contact
    response.should redirect_to(home_url)
  end
  
  it "should accept the connection" do
    Connection.should_receive(:accept).with(@person, @contact).
      and_return(true)
    put :update, :person_id => @contact
    response.should redirect_to(home_url)
  end
  
  it "should end a connection" do
    Connection.should_receive(:breakup).with(@person, @contact).
      and_return(true)
    delete :destroy, :person_id => @contact
    response.should redirect_to(home_url)
  end
end