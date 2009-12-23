require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/neighborhoods/index.html.erb" do
  include NeighborhoodsHelper

  before(:each) do
    assigns[:neighborhoods] = [
      stub_model(Neighborhood,
        :name => "value for name",
        :description => "value for description",
        :parent_id => 1
      ),
      stub_model(Neighborhood,
        :name => "value for name",
        :description => "value for description",
        :parent_id => 1
      )
    ]
  end

  it "renders a list of neighborhoods" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
