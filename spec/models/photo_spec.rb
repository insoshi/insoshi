# == Schema Information
#
# Table name: photos
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  content_type   :string(255)
#  thumbnail      :string(255)
#  size           :integer
#  width          :integer
#  height         :integer
#  primary        :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  picture        :string(255)
#  photoable_id   :integer
#  photoable_type :string(255)
#  picture_for    :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Photo do

  before(:each) do
    @filename = "rails.png"
    @person = people(:quentin)
    @image = uploaded_file(@filename, "image/png")
  end

  it "should upload successfully" do
    new_photo.should be_valid
  end

  it "should be able to make a primary photo" do
    new_photo(:primary => true).should be_primary
  end

  it "should be able to make a non-primary photo" do
    new_photo(:primary => false).should_not be_primary
  end


  it "should have an associated person" do
    new_photo.photoable.should == @person
  end

  private

    def new_photo(options = {})
      Photo.new({ :uploaded_data => @image,
                  :photoable        => @person }.merge(options))
    end
end
