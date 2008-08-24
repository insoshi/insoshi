require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.erb" do
    
  before(:each) do
    @controller.params[:controller] = "people"
    @person = login_as(:quentin)
    @person.description = "Foo *bar*"
    assigns[:person] = @person
    assigns[:blog] = @person.blog
    assigns[:posts] = @person.blog.posts.paginate(:page => 1)
    assigns[:galleries] = @person.galleries.paginate(:page => 1)
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
