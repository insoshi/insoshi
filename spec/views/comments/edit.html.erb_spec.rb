require File.dirname(__FILE__) + '/../../spec_helper'

describe "/comments/edit.html.erb" do
  include CommentsHelper
  
  before do
    @comment = mock_model(Comment)
    @comment.stub!(:person_id).and_return("1")
    @comment.stub!(:blog_id).and_return("1")
    @comment.stub!(:body).and_return("MyText")
    @comment.stub!(:type).and_return("MyString")
    assigns[:comment] = @comment
  end

  it "should render edit form" do
    render "/comments/edit.html.erb"
    
    response.should have_tag("form[action=#{comment_path(@comment)}][method=post]") do
      with_tag('textarea#comment_body[name=?]', "comment[body]")
      with_tag('input#comment_type[name=?]', "comment[type]")
    end
  end
end


