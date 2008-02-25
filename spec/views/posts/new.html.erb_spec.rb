require File.dirname(__FILE__) + '/../../spec_helper'

describe "/posts/new.html.erb" do
  include PostsHelper
  
  before(:each) do
    @post = mock_model(Post)
    @post.stub!(:new_record?).and_return(true)
    @post.stub!(:blog_id).and_return("1")
    @post.stub!(:topic_id).and_return("1")
    @post.stub!(:person_id).and_return("1")
    @post.stub!(:body).and_return("MyText")
    assigns[:post] = @post
  end

  it "should render new form" do
    render "/posts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", posts_path) do
      with_tag("textarea#post_body[name=?]", "post[body]")
    end
  end
end


