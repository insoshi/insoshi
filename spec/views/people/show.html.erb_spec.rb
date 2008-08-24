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
    assigns[:common_contacts] = []
    render "/people/show.html.erb"
  end

  it "should have the right title" do
    response.should have_tag("h2", /#{@person.name}/)
  end
  
  it "should have a Markdown-ed description if BlueCloth is present" do
    begin
      BlueCloth.new("used to raise an exeption")
      response.should have_tag("em", "bar")
    rescue NameError
      nil
    end
  end 
end
