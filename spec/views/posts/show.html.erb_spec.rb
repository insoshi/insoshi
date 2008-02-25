require File.dirname(__FILE__) + '/../../spec_helper'

describe "/posts/show.html.erb" do
  include PostsHelper
  
  before(:each) do
    @post = mock_model(Post)
    @post.stub!(:blog_id).and_return("1")
    @post.stub!(:topic_id).and_return("1")
    @post.stub!(:person_id).and_return("1")
    @post.stub!(:body).and_return("MyText")

    assigns[:post] = @post
  end

  it "should render attributes in <p>" do
    render "/posts/show.html.erb"
    response.should have_text(/MyText/)
  end
end

