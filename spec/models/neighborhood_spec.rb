# == Schema Information
#
# Table name: neighborhoods
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  parent_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Neighborhood do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :parent_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Neighborhood.create!(@valid_attributes)
  end
end
