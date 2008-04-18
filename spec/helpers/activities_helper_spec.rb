require File.dirname(__FILE__) + '/../spec_helper'
include SharedHelper
describe ActivitiesHelper do

  before(:each) do
    @current_person = login_as(:aaron)
    # It sucks that RSpec makes me do this.
    self.stub!(:logged_in?).and_return(true)
    self.stub!(:current_person).and_return(people(:aaron))
  end
  
  it "should have the right message for a wall comment" do
    person = people(:quentin)
    comment = person.comments.create(:body => "The body",
                                     :commenter => @current_person)
    activity = Activity.find_by_item_id(comment)
    feed_message(activity).should =~ /#{person.name}'s wall/
  end
  
  it "should have the right message for a blog comment" do
    post = posts(:blog_post)
    comment = post.comments.create(:body => "The body",
                                   :commenter => @current_person)
    activity = Activity.find_by_item_id(comment)
    feed_message(activity).should =~ /blog post/
  end
end
