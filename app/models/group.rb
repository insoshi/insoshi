class Group < ActiveRecord::Base
  include ActivityLogger
  
  validates_presence_of :name, :person_id
  
  has_many :photos, :dependent => :destroy, :order => "created_at"
  has_and_belongs_to_many :people, :order => "name DESC"
  has_many :exchanges, :order => "created_at DESC"
  
  belongs_to :owner, :class_name => "Person", :foreign_key => "person_id"
  
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  after_save :log_activity
  
  is_indexed :fields => [ 'name', 'description']
  
  ## Photo helpers

  def photo
    # This should only have one entry, but be paranoid.
    photos.find_all_by_primary(true).first
  end

  # Return all the photos other than the primary one
  def other_photos
    photos.length > 1 ? photos - [photo] : []
  end

  def main_photo
    photo.nil? ? "g_default.png" : photo.public_filename
  end

  def thumbnail
    photo.nil? ? "g_default_thumbnail.png" : photo.public_filename(:thumbnail)
  end

  def icon
    photo.nil? ? "g_default_icon.png" : photo.public_filename(:icon)
  end

  def bounded_icon
    photo.nil? ? "g_default_icon.png" : photo.public_filename(:bounded_icon)
  end

  # Return the photos ordered by primary first, then by created_at.
  # They are already ordered by created_at as per the has_many association.
  def sorted_photos
    # The call to partition ensures that the primary photo comes first.
    # photos.partition(&:primary) => [[primary], [other one, another one]]
    # flatten yields [primary, other one, another one]
    @sorted_photos ||= photos.partition(&:primary).flatten
  end
  
  
  private
  
  def log_activity
    activity = Activity.create!(:item => self, :person => Person.find(self.person_id))
    add_activities(:activity => activity, :person => Person.find(self.person_id))
  end
  
end
