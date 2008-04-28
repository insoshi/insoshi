require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.erb" do
    
  before(:each) do
    @person = login_as(:quentin)
    @person.description = "Foo *bar*"
    assigns[:person] = @person
    assigns[:some_contacts] = @person.some_contacts
    assigns[:common_connections] = []
    render "/people/show.html.erb"
  end

  it "should have the right title" do
    response.should have_tag("h2", /#{@person.name}/)
  end
  
  it "should have a description rendered by Markdown" do
    response.should have_tag("em", "bar")
  end
 
end
