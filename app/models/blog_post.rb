# == Schema Information
# Schema version: 19
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

class BlogPost < Post
  
  MAX_TITLE = SMALL_STRING_LENGTH
  MAX_BODY  = MAX_TEXT_LENGTH
  
  belongs_to :blog
  has_many :comments, :as => :commentable, :order => :created_at
  
  validates_presence_of :title, :body
  validates_length_of :title, :maximum => MAX_TITLE
  validates_length_of :body, :maximum => MAX_BODY
  
  after_create :log_activity
  
  private
  
    def log_activity
      add_activities(:item => self, :person => blog.person)
    end
end
