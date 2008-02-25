require File.dirname(__FILE__) + '/../spec_helper'

describe Topic do

  it "should be valid" do
    Topic.new(:name => "A topic").should be_valid
  end
  
  it "should require a name" do
    topic = Topic.new
    topic.should_not be_valid
    topic.errors.on(:name).should_not be_empty
  end

  it "should have a max name length" do
    Topic.should have_maximum(:name, MAX_STRING_LENGTH)
  end
  
  it "should have many posts" do
    Topic.new.posts.should be_a_kind_of(Array)
  end
  
  it "should belong to a person" do
    quentin = people(:quentin)
    topic = Topic.new(:person => quentin)
    topic.person.should == quentin
  end
end
