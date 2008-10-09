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
