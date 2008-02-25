require File.dirname(__FILE__) + '/../../spec_helper'

describe "/forums/show.html.erb" do
  include ForumsHelper
  
  before(:each) do
    @forum = mock_model(Forum)
    @forum.stub!(:name).and_return("MyString")
    @forum.stub!(:description).and_return("MyText")
    @forum.stub!(:topics_count).and_return("1")

    assigns[:forum] = @forum
  end

  it "should render attributes in <p>" do
    render "/forums/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
    response.should have_text(/1/)
  end
end

