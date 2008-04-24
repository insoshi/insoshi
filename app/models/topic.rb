# == Schema Information
# Schema version: 19
#
# Table name: topics
#
#  id                :integer         not null, primary key
#  forum_id          :integer         
#  person_id         :integer         
#  name              :string(255)     
#  forum_posts_count :integer         default(0), not null
#  created_at        :datetime        
#  updated_at        :datetime        
#

class Topic < ActiveRecord::Base
  include ActivityLogger
  
  MAX_NAME = MEDIUM_STRING_LENGTH
  NUM_RECENT = 6
  
  belongs_to :forum, :counter_cache => true
  belongs_to :person
  has_many :posts, :order => :created_at, :dependent => :destroy,
                   :class_name => "ForumPost"
  
  validates_presence_of :name, :forum, :person
  validates_length_of :name, :maximum => MAX_NAME
  
  after_create :log_activity
  
  def self.find_recent
    find(:all, :order => "created_at DESC", :limit => NUM_RECENT)
  end
  
  private
  
    def log_activity
      add_activities(:item => self, :person => person)
    end
end
