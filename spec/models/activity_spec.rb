require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  before(:each) do
    @person = people(:quentin)
  end

  it "should delete a post activity along with its parent item" do
    @post = ForumPost.create(:body => "Hey there", :topic => topics(:one),
                             :person => people(:quentin))
    destroy_should_remove_activity(@post)
  end
  
  it "should delete a comment activity along with its parent item" do
    @comment = WallComment.create(:body => "Hey there",
                                  :commentable => people(:quentin),
                                  :commenter => people(:aaron))
    destroy_should_remove_activity(@comment)
  end
  
  it "should delete an associated connection" do
    @person = people(:quentin)
    @contact = people(:aaron)
    Connection.request(@person, @contact)
    Connection.accept(@person, @contact)
    @connection = Connection.conn(@person, @contact)
    destroy_should_remove_activity(@connection, :breakup)
  end
  
  private
  
  # TODO: do this in a more RSpecky way.
  def destroy_should_remove_activity(obj, method = :destroy)
    Activity.find_by_item_id(obj).should_not be_nil
    obj.send(method)
    Activity.find_by_item_id(obj).should be_nil
  end
end
