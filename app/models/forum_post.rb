require 'texticle/searchable'

class ForumPost < Post
  extend Searchable(:body)

  attr_accessible :body
  attr_accessible *attribute_names, :as => :admin
  
  belongs_to :topic,  :counter_cache => true, :touch => true
  belongs_to :person, :counter_cache => true
  
  validates_presence_of :body, :person
  validates_length_of :body, :maximum => 5000
  
  after_create :log_activity
  after_create :send_forum_notifications

  def send_forum_notifications
    peeps = topic.forum.group.memberships.listening.map {|m| m.person}
    after_transaction do
      peeps.each do |peep|
        PersonMailerQueue.forum_post_notification(peep, self)
      end
    end
  end

  private

 def log_activity
    add_activities(:item => self, :person => person, :group => self.topic.forum.group)
  end
end
