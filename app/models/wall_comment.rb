class WallComment < Comment
  belongs_to :person
  validates_presence_of :person
end