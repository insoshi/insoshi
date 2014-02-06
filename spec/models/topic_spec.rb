require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do

  before(:each) do
    @person = people(:quentin)
    @topic = forums(:one).topics.build(:name => "A topic")
    @topic.person = @person
  end

  it "should be valid" do
    @topic.should be_valid
  end

  it "should require a name" do
    topic = Topic.new
    topic.should_not be_valid
    topic.errors[:name].should_not be_empty
  end

  it "should have many posts" do
    @topic.posts.should be_a_kind_of(Array)
  end

  it "should belong to a person" do
    quentin = people(:quentin)
    topic = Topic.new
    topic.person = quentin
    topic.person.should == quentin
  end

  describe "associations" do

    before(:each) do
      @topic.save!
    end

    it "should have an activity" do
      Activity.find_by_item_id(@topic).should_not be_nil
    end
  end
end
