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

class BlogPostComment < Comment  
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  belongs_to :post, :counter_cache => true, :foreign_key => "blog_post_id"
    
  validates_presence_of :commenter
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
  
  after_create :log_activity
  
  private
  
    def log_activity
      activity = Activity.create!(:item => self, :person => commenter)
      add_activities(:activity => activity, :person => post.blog.person)
      add_activities(:activity => activity, :person => commenter)
    end
end
