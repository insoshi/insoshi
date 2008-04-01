# == Schema Information
# Schema version: 13
#
# Table name: comments
#
#  id           :integer(11)     not null, primary key
#  person_id    :integer(11)     
#  commenter_id :integer(11)     
#  blog_post_id :integer(11)     
#  body         :text            
#  type         :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Comment < ActiveRecord::Base
  include ActivityLogger
  validates_presence_of :body
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
end
