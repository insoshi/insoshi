require File.dirname(__FILE__) + '/../../spec_helper'

describe "/comments/show.html.erb" do
  include CommentsHelper
  
  before(:each) do
    @comment = mock_model(Comment)
    @comment.stub!(:person_id).and_return("1")
    @comment.stub!(:blog_id).and_return("1")
    @comment.stub!(:body).and_return("MyText")
    @comment.stub!(:type).and_return("MyString")

    assigns[:comment] = @comment
  end

  it "should render attributes in <p>" do
    render "/comments/show.html.erb"
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
  end
end

