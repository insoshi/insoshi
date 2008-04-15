# == Schema Information
# Schema version: 16
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

class BlogPostComment < Comment
  belongs_to :post, :counter_cache => true, :foreign_key => "blog_post_id"
end
