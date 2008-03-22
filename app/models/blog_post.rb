# == Schema Information
# Schema version: 12
#
# Table name: posts
#
#  id                       :integer(11)     not null, primary key
#  blog_id                  :integer(11)     
#  topic_id                 :integer(11)     
#  person_id                :integer(11)     
#  title                    :string(255)     
#  body                     :text            
#  blog_post_comments_count :integer(11)     default(0), not null
#  type                     :string(255)     
#  created_at               :datetime        
#  updated_at               :datetime        
#

class BlogPost < Post
  
  MAX_TITLE = SMALL_STRING_LENGTH
  MAX_BODY  = MEDIUM_TEXT_LENGTH
  
  belongs_to :blog
  has_many :comments, :class_name => "BlogPostComment",
                      :order => :created_at, :dependent => :destroy
  has_one :event, :foreign_key => "instance_id", :dependent => :destroy
  
  validates_presence_of :title, :body
  validates_length_of :title, :maximum => MAX_TITLE
  validates_length_of :body, :maximum => MAX_BODY
  
  after_create :log_event
  
  private
  
    def log_event
      BlogPostEvent.create!(:person => blog.person, :instance => self)
    end
end
