# == Schema Information
# Schema version: 20080916002106
#
# Table name: posts
#
#  id         :integer(4)      not null, primary key
#  blog_id    :integer(4)      
#  topic_id   :integer(4)      
#  person_id  :integer(4)      
#  title      :string(255)     
#  body       :text            
#  type       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class BlogPost < Post
  
  MAX_TITLE = MEDIUM_STRING_LENGTH
  MAX_BODY  = MAX_TEXT_LENGTH
  
  attr_accessible :title, :body
  
  belongs_to :blog
  has_many :comments, :as => :commentable, :order => :created_at,
                      :dependent => :destroy
  
  validates_presence_of :title, :body
  validates_length_of :title, :maximum => MAX_TITLE
  validates_length_of :body, :maximum => MAX_BODY
  
  after_create :log_activity
  
  private
  
    def log_activity
      add_activities(:item => self, :person => blog.person)
    end
end
