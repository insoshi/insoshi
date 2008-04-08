# == Schema Information
# Schema version: 15
#
# Table name: comments
#
#  id           :integer         not null, primary key
#  person_id    :integer         
#  commenter_id :integer         
#  blog_post_id :integer         
#  body         :text            
#  type         :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Comment < ActiveRecord::Base
  include ActivityLogger
  validates_presence_of :body, :commenter
  belongs_to :commentable, :polymorphic => true
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
end
