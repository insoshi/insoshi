require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/neighborhoods/show.html.erb" do
  include NeighborhoodsHelper
  before(:each) do
    assigns[:neighborhood] = @neighborhood = stub_model(Neighborhood,
      :name => "value for name",
      :description => "value for description",
      :parent_id => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/1/)
  end
end
