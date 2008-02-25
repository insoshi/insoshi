require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forums/new.html.erb" do
  include ForumsHelper
  
  before(:each) do
    @forum = mock_model(Forum)
    @forum.stub!(:new_record?).and_return(true)
    @forum.stub!(:name).and_return("MyString")
    @forum.stub!(:description).and_return("MyText")
    @forum.stub!(:topics_count).and_return("1")
    assigns[:forum] = @forum
  end

  it "should render new form" do
    render "/forums/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", forums_path) do
      with_tag("input#forum_name[name=?]", "forum[name]")
      with_tag("textarea#forum_description[name=?]", "forum[description]")
      with_tag("input#forum_topics_count[name=?]", "forum[topics_count]")
    end
  end
end


