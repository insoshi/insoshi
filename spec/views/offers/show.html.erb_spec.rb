require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/offers/show" do
  before(:each) do
    render 'offers/show'
  end

  #Delete this example and add some real ones or delete this file
  it "should tell you where to find the file" do
    response.should have_tag('p', %r[Find me in app/views/offers/show])
  end
end
