# == Schema Information
# Schema version: 10
#
# Table name: comments
#
#  id           :integer(11)     not null, primary key
#  person_id    :integer(11)     
#  commenter_id :integer(11)     
#  blog_post_id :integer(11)     
#  body         :text            
#  type         :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class WallComment < Comment
  belongs_to :person, :counter_cache => true
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  has_one :event, :foreign_key => "instance_id", :dependent => :destroy
  
  validates_presence_of :commenter
  validates_length_of :body, :maximum => SMALL_TEXT_LENGTH
  
  after_create :log_event
  
  private
  
    def log_event
      BlogPostCommentEvent.create!(:person => person, :instance => self)
    end
end
