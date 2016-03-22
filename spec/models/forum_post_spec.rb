# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  blog_id    :integer
#  topic_id   :integer
#  person_id  :integer
#  title      :string(255)
#  body       :text
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require File.dirname(__FILE__) + '/../spec_helper'

describe ForumPost do

  fixtures :topics, :forums, :groups

  before(:each) do
    @post = ForumPost.new(:body => "Hey there")
    @post.topic  = topics(:one)
    @post.person = people(:quentin)
  end

  it "should be valid" do
    @post.should be_valid
  end

  it "should require a body" do
    post = ForumPost.new
    post.should_not be_valid
    post.errors[:body].should_not be_empty
  end

  describe "associations" do

    before(:each) do
      @post.save!
      @activity = Activity.find_by_item_id(@post)
    end

    it "should have an activity" do
      @activity.should_not be_nil
    end

    it "should add an activity to the poster" do
      @post.person.recent_activity.should contain(@activity)
    end
  end
end
