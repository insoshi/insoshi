require File.dirname(__FILE__) + '/../../spec_helper'

describe "/topics/edit.html.erb" do
  include TopicsHelper
  
  before do
    @topic = mock_model(Topic)
    @topic.stub!(:forum_id).and_return("1")
    @topic.stub!(:person_id).and_return("1")
    @topic.stub!(:name).and_return("1")
    @topic.stub!(:posts_count).and_return("1")
    assigns[:topic] = @topic
  end

  it "should render edit form" do
    render "/topics/edit.html.erb"
    
    response.should have_tag("form[action=#{topic_path(@topic)}][method=post]") do
      with_tag('input#topic_name[name=?]', "topic[name]")
      with_tag('input#topic_posts_count[name=?]', "topic[posts_count]")
    end
  end
end


