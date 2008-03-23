# == Schema Information
# Schema version: 12
#
# Table name: events
#
#  id         :integer(11)     not null, primary key
#  public     :boolean(1)      
#  item_id    :integer(11)     
#  item_type  :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Event < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  has_many :feeds
  
  # Return the proper person associated to an event.
  def person
    case item.class.to_s
    when "BlogPost"
      item.blog.person
    when "BlogPostComment"
      item.commenter
    when "Connection"
      item.person
    when "ForumPost"
      item.person
    when "Topic"
      item.person
    when "WallComment"
      item.person
    end
  end
end
