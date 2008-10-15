# == Schema Information
# Schema version: 20080916002106
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  commenter_id     :integer(4)      
#  commentable_id   :integer(4)      
#  commentable_type :string(255)     default(""), not null
#  body             :text            
#  created_at       :datetime        
#  updated_at       :datetime        
#

class Comment < ActiveRecord::Base
  include ActivityLogger
  extend PreferencesHelper
  
  attr_accessor :commented_person, :send_mail

  attr_accessible :body
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"

  belongs_to :person, :counter_cache => true
  belongs_to :post
  belongs_to :event

  has_many :activities, :foreign_key => "item_id",
                        :conditions => "item_type = 'Comment'",
                        :dependent => :destroy

  validates_presence_of :body, :commenter
  validates_length_of :body, :maximum => MAX_TEXT_LENGTH
  validates_length_of :body, :maximum => MEDIUM_TEXT_LENGTH,
                             :if => :wall_comment?
  
  after_create :log_activity, :send_receipt_reminder
    
  # Return the person for the thing commented on.
  # For example, for blog post comments it's the blog's person
  # For wall comments, it's the person himself.
  def commented_person
    @commented_person ||= case commentable.class.to_s
                          when "Person"
                            commentable
                          when "BlogPost"
                            commentable.blog.person
                          when "Event"
                            commentable.person
                          end
  end
  
  private
    
    def wall_comment?
      commentable.class.to_s == "Person"
    end
  
    def blog_post_comment?
      commentable.class.to_s == "BlogPost"
    end

    def event_comment?
      commentable.class.to_s == "Event"
    end
    
    def notifications?
      if wall_comment?
        commented_person.wall_comment_notifications?
      elsif blog_post_comment?
        commented_person.blog_comment_notifications?
      end
    end
  
    def log_activity
      activity = Activity.create!(:item => self, :person => commenter)
      add_activities(:activity => activity, :person => commenter)
      unless commented_person.nil? or commenter == commented_person
        add_activities(:activity => activity, :person => commented_person,
                       :include_person => true)
      end
    end
    
    def send_receipt_reminder
      return if commenter == commented_person
      if wall_comment?
        @send_mail ||= Comment.global_prefs.email_notifications? &&
                       commented_person.wall_comment_notifications?
        PersonMailer.deliver_wall_comment_notification(self) if @send_mail
      elsif blog_post_comment?
        @send_mail ||= Comment.global_prefs.email_notifications? &&
                       commented_person.blog_comment_notifications?
        PersonMailer.deliver_blog_comment_notification(self) if @send_mail
      end
    end
end
