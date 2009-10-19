require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/neighborhoods/edit.html.erb" do
  include NeighborhoodsHelper

  before(:each) do
    assigns[:neighborhood] = @neighborhood = stub_model(Neighborhood,
      :new_record? => false,
      :name => "value for name",
      :description => "value for description",
      :parent_id => 1
    )
  end

  it "renders the edit neighborhood form" do
    render

    response.should have_tag("form[action=#{neighborhood_path(@neighborhood)}][method=post]") do
      with_tag('input#neighborhood_name[name=?]', "neighborhood[name]")
      with_tag('textarea#neighborhood_description[name=?]', "neighborhood[description]")
      with_tag('input#neighborhood_parent_id[name=?]', "neighborhood[parent_id]")
    end
  end
end
