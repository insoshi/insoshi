# == Schema Information
# Schema version: 28
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

class ForumPost < Post
  is_indexed :fields => [ 'body' ],
             :conditions => "type = 'ForumPost'",
             :include => [{:association_name => 'topic', :field => 'name'}]

  attr_accessible :body
  
  belongs_to :topic,  :counter_cache => true
  belongs_to :person, :counter_cache => true
  
  validates_presence_of :body, :person
  validates_length_of :body, :maximum => 5000
  
  after_create :log_activity
    
  private
  
    def log_activity
      add_activities(:item => self, :person => person)
    end
end
