# == Schema Information
# Schema version: 9
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
  validates_presence_of :body
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
end
