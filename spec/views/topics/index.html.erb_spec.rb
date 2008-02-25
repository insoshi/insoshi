require File.dirname(__FILE__) + '/../../spec_helper'

describe "/topics/index.html.erb" do
  include TopicsHelper
  
  before(:each) do
    topic_98 = mock_model(Topic)
    topic_98.should_receive(:forum_id).and_return("1")
    topic_98.should_receive(:person_id).and_return("1")
    topic_98.should_receive(:name).and_return("1")
    topic_98.should_receive(:posts_count).and_return("1")
    topic_99 = mock_model(Topic)
    topic_99.should_receive(:forum_id).and_return("1")
    topic_99.should_receive(:person_id).and_return("1")
    topic_99.should_receive(:name).and_return("1")
    topic_99.should_receive(:posts_count).and_return("1")

    assigns[:topics] = [topic_98, topic_99]
  end

  it "should render list of topics" do
    render "/topics/index.html.erb"
    response.should have_tag("tr>td", "1", 2)
    response.should have_tag("tr>td", "1", 2)
  end
end

