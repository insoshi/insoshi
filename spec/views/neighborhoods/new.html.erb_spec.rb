require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/neighborhoods/new.html.erb" do
  include NeighborhoodsHelper

  before(:each) do
    assigns[:neighborhood] = stub_model(Neighborhood,
      :new_record? => true,
      :name => "value for name",
      :description => "value for description",
      :parent_id => 1
    )
  end

  it "renders new neighborhood form" do
    render

    response.should have_tag("form[action=?][method=post]", neighborhoods_path) do
      with_tag("input#neighborhood_name[name=?]", "neighborhood[name]")
      with_tag("textarea#neighborhood_description[name=?]", "neighborhood[description]")
      with_tag("input#neighborhood_parent_id[name=?]", "neighborhood[parent_id]")
    end
  end
end
