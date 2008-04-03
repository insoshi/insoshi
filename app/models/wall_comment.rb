# == Schema Information
# Schema version: 15
#
# Table name: comments
#
#  id           :integer         not null, primary key
#  person_id    :integer         
#  commenter_id :integer         
#  blog_post_id :integer         
#  body         :text            
#  type         :string(255)     
#  created_at   :datetime        
#  updated_at   :datetime        
#

class WallComment < Comment
  belongs_to :person, :counter_cache => true
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  
  validates_presence_of :commenter
  validates_length_of :body, :maximum => SMALL_TEXT_LENGTH
  
  after_create :log_activity
  
  private
  
    def log_activity
      add_activities(:item => self, :person => person)
    end
end
