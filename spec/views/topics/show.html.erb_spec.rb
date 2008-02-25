require File.dirname(__FILE__) + '/../../spec_helper'

describe "/topics/show.html.erb" do
  include TopicsHelper
  
  before(:each) do
    @topic = mock_model(Topic)
    @topic.stub!(:forum_id).and_return("1")
    @topic.stub!(:person_id).and_return("1")
    @topic.stub!(:name).and_return("1")
    @topic.stub!(:posts_count).and_return("1")

    assigns[:topic] = @topic
  end

  it "should render attributes in <p>" do
    render "/topics/show.html.erb"
    response.should have_text(/1/)
    response.should have_text(/1/)
  end
end

