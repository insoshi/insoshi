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