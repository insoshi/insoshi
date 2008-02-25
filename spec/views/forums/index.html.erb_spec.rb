require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forums/index.html.erb" do
  include ForumsHelper
  
  before(:each) do
    forum_98 = mock_model(Forum)
    forum_98.should_receive(:name).and_return("MyString")
    forum_98.should_receive(:description).and_return("MyText")
    forum_98.should_receive(:topics_count).and_return("1")
    forum_99 = mock_model(Forum)
    forum_99.should_receive(:name).and_return("MyString")
    forum_99.should_receive(:description).and_return("MyText")
    forum_99.should_receive(:topics_count).and_return("1")

    assigns[:forums] = [forum_98, forum_99]
  end

  it "should render list of forums" do
    render "/forums/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "1", 2)
  end
end

