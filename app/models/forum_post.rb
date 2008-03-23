# == Schema Information
# Schema version: 13
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
  belongs_to :topic,  :counter_cache => true
  belongs_to :person, :counter_cache => true
  
  validates_presence_of :body, :topic, :person
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
  
  after_create :log_event
  
  private
  
    def log_event
      event = Event.create!(:item => self, :person => person)
      add_events(person, event)
    end
    
    def add_events(person, event)
      person.events << event
      person.contacts.each { |c| c.events << event }
    end
end
