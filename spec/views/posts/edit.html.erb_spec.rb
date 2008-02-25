require File.dirname(__FILE__) + '/../../spec_helper'

describe "/posts/edit.html.erb" do
  include PostsHelper
  
  before do
    @post = mock_model(Post)
    @post.stub!(:blog_id).and_return("1")
    @post.stub!(:topic_id).and_return("1")
    @post.stub!(:person_id).and_return("1")
    @post.stub!(:body).and_return("MyText")
    assigns[:post] = @post
  end

  it "should render edit form" do
    render "/posts/edit.html.erb"
    
    response.should have_tag("form[action=#{post_path(@post)}][method=post]") do
      with_tag('textarea#post_body[name=?]', "post[body]")
    end
  end
end


