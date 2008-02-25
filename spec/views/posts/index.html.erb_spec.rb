require File.dirname(__FILE__) + '/../../spec_helper'

describe "/posts/index.html.erb" do
  include PostsHelper
  
  before(:each) do
    post_98 = mock_model(Post)
    post_98.should_receive(:blog_id).and_return("1")
    post_98.should_receive(:topic_id).and_return("1")
    post_98.should_receive(:person_id).and_return("1")
    post_98.should_receive(:body).and_return("MyText")
    post_99 = mock_model(Post)
    post_99.should_receive(:blog_id).and_return("1")
    post_99.should_receive(:topic_id).and_return("1")
    post_99.should_receive(:person_id).and_return("1")
    post_99.should_receive(:body).and_return("MyText")

    assigns[:posts] = [post_98, post_99]
  end

  it "should render list of posts" do
    render "/posts/index.html.erb"
    response.should have_tag("tr>td", "MyText", 2)
  end
end

