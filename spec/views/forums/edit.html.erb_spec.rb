require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forums/edit.html.erb" do
  include ForumsHelper
  
  before do
    @forum = mock_model(Forum)
    @forum.stub!(:name).and_return("MyString")
    @forum.stub!(:description).and_return("MyText")
    @forum.stub!(:topics_count).and_return("1")
    assigns[:forum] = @forum
  end

  it "should render edit form" do
    render "/forums/edit.html.erb"
    
    response.should have_tag("form[action=#{forum_path(@forum)}][method=post]") do
      with_tag('input#forum_name[name=?]', "forum[name]")
      with_tag('textarea#forum_description[name=?]', "forum[description]")
      with_tag('input#forum_topics_count[name=?]', "forum[topics_count]")
    end
  end
end


