# == Schema Information
# Schema version: 17
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

# class WallComment < Comment
#   # belongs_to :person, :counter_cache => true
# #  validates_length_of :body, :maximum => SMALL_TEXT_LENGTH
# end
