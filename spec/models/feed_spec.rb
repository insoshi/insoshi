# == Schema Information
#
# Table name: feeds
#
#  id          :integer          not null, primary key
#  person_id   :integer
#  activity_id :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  before(:each) do
    @feed = Feed.new
  end

  it "should be valid" do
    @feed.should be_valid
  end
end
