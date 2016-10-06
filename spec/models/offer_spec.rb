# == Schema Information
#
# Table name: offers
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  description     :text
#  price           :decimal(8, 2)    default(0.0)
#  expiration_date :datetime
#  person_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  total_available :integer          default(1)
#  available_count :integer
#  group_id        :integer
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Offer do
  before(:each) do
    Preference.create
    p = people(:quentin)
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :price => 9.99,
      :expiration_date => Date.today,
      :total_available => 1,
      :group_id => 1,
      :person => p 
    }
  end
=begin
  XXX offer examples currently in group_spec

  it "should create a new instance given valid attributes" do
    Offer.create!(@valid_attributes)
  end
=end
end
