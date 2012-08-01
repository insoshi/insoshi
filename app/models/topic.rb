# == Schema Information
# Schema version: 20090216032013
#
# Table name: topics
#
#  id                :integer(4)      not null, primary key
#  forum_id          :integer(4)      
#  person_id         :integer(4)      
#  name              :string(255)     
#  forum_posts_count :integer(4)      default(0), not null
#  created_at        :datetime        
#  updated_at        :datetime        
#

class Topic < ActiveRecord::Base
  include ActivityLogger
  
  MAX_NAME = 100
  NUM_RECENT = 6
  DEFAULT_REFRESH_SECONDS = 30
  
  attr_accessible :name
  
  belongs_to :forum, :counter_cache => true
  belongs_to :person
  has_many :posts, :order => 'created_at DESC', :dependent => :destroy,
                   :class_name => "ForumPost"
  has_many :viewers, :dependent => :destroy
  has_many :activities, :as => :item, :dependent => :destroy
  validates_presence_of :name, :forum, :person
  validates_length_of :name, :maximum => MAX_NAME
  
  after_create :log_activity
  
  def self.find_recent
    find(:all, :order => "created_at DESC", :limit => NUM_RECENT)
  end

  def self.find_recently_active(forum, page = 1)
    topics = forum.topics.paginate(:page => page)
  end

  def update_viewer(person)
    current_viewer = self.viewers.find_or_create_by_person_id(person.id)
    current_viewer.touch
  end

  def current_viewers(seconds_ago)
    self.viewers.all(:conditions => ['updated_at > ?', Time.now.ago(seconds_ago).utc], :include => :person)
  end

  def posts_since_last_refresh(last_refresh_time, person_id)
    self.posts.all(:conditions => ['created_at > ? and person_id != ?', Time.at(last_refresh_time + 1).utc, person_id], 
                   :include => :person, :order => 'created_at DESC')
  end

  private
  
    def log_activity
      add_activities(:item => self, :person => person, :group => self.forum.group)
    end
end
