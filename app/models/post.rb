# == Schema Information
# Schema version: 34
#
# Table name: posts
#
#  id                       :integer         not null, primary key
#  blog_id                  :integer         
#  topic_id                 :integer         
#  person_id                :integer         
#  title                    :string(255)     
#  body                     :text            
#  blog_post_comments_count :integer         default(0), not null
#  type                     :string(255)     
#  created_at               :datetime        
#  updated_at               :datetime        
#

class Post < ActiveRecord::Base
  include ActivityLogger
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
end
