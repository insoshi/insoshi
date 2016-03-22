# == Schema Information
#
# Table name: person_metadata
#
#  id                   :integer          not null, primary key
#  key                  :string(255)
#  value                :string(255)
#  person_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  form_signup_field_id :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe PersonMetadatum do
  before(:each) do
    @person = people(:quentin)
    @person_metadata = PersonMetadatum.new(
      :key => "key1",
      :person_id => @person.id,
    )
  end

  it "should be valid" do
    @person_metadata.should be_valid
  end
end
