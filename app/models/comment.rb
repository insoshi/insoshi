# == Schema Information
# Schema version: 15
#
# Table name: comments
#
#  id               :integer(11)     not null, primary key
#  commenter_id     :integer(11)     
#  commentable_id   :integer(11)     
#  commentable_type :string(255)     default(""), not null
#  body             :text            
#  created_at       :datetime        
#  updated_at       :datetime        
#

class Comment < ActiveRecord::Base
  include ActivityLogger
  validates_presence_of :body, :commenter
  belongs_to :commentable, :polymorphic => true
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
end
