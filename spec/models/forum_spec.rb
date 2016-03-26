# == Schema Information
#
# Table name: forums
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  description   :text
#  topics_count  :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  group_id      :integer
#  worldwritable :boolean          default(FALSE)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Forum do
  it "should be valid" do
    Forum.new.should be_valid
  end
  
  it "should have topics" do
    forums(:one).topics.should be_a_kind_of(Array)
  end
  
  it "should have posts" do
    forums(:one).posts.should be_a_kind_of(Array)
  end
end
