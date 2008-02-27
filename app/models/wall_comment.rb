class WallComment < Comment
  belongs_to :person, :counter_cache => true
  belongs_to :commenter, :class_name => "Person",
                         :foreign_key => "commenter_id"
  validates_presence_of :person
end