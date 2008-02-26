require File.dirname(__FILE__) + '/../../spec_helper'

describe "/comments/new.html.erb" do
  include CommentsHelper
  
  before(:each) do
    @comment = mock_model(Comment)
    @comment.stub!(:new_record?).and_return(true)
    @comment.stub!(:person_id).and_return("1")
    @comment.stub!(:blog_id).and_return("1")
    @comment.stub!(:body).and_return("MyText")
    @comment.stub!(:type).and_return("MyString")
    assigns[:comment] = @comment
  end

  it "should render new form" do
    render "/comments/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", comments_path) do
      with_tag("textarea#comment_body[name=?]", "comment[body]")
      with_tag("input#comment_type[name=?]", "comment[type]")
    end
  end
end


