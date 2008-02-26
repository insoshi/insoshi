class WallComment < Comment
  belongs_to :person, :counter_cache => true
  validates_presence_of :person
end