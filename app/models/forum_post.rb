# == Schema Information
# Schema version: 20090216032013
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
  index do 
    body
  end

# not sure how to do this in texticle
#   is_indexed :fields => [ 'body' ],
#              :conditions => "type = 'ForumPost'",
#              :include => [{:association_name => 'topic', :field => 'name'}]

  attr_accessible :body
  attr_accessible *attribute_names, :as => :admin
  
  belongs_to :topic,  :counter_cache => true, :touch => true
  belongs_to :person, :counter_cache => true
  
  validates_presence_of :body, :person
  validates_length_of :body, :maximum => 5000
  
  after_create :log_activity
  after_create :send_forum_notifications

  def send_forum_notifications
    Cheepnis.enqueue(self)
  end
  
  def perform
    do_send_forum_notifications
  end

  def do_send_forum_notifications
    peeps = topic.forum.group.memberships.listening.map {|m| m.person}
    
    peeps.each do |peep|
      logger.info("forum_post: sending email to #{peep.id}: #{peep.name}")
      PersonMailer.forum_post_notification(peep, self).deliver
    end
  end

  private

 def log_activity
    add_activities(:item => self, :person => person, :group => self.topic.forum.group)
  end
end
