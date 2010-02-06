class Group < ActiveRecord::Base
  include ActivityLogger
  
  validates_presence_of :name, :person_id

  has_one :forum
  has_many :photos, :dependent => :destroy, :order => "created_at"
  has_many :exchanges, :order => "created_at DESC"
  has_many :memberships, :dependent => :destroy
  has_many :people, :through => :memberships, 
    :conditions => "status = 0", :order => "name DESC"
  has_many :pending_request, :through => :memberships, :source => "person",
    :conditions => "status = 2", :order => "name DESC"
  
  belongs_to :owner, :class_name => "Person", :foreign_key => "person_id"
  
  has_many :activities, :foreign_key => "item_id", :conditions => "item_type = 'Group'", :dependent => :destroy
 
  after_create :create_owner_membership
  after_create :create_forum
  after_save :log_activity
  
  index do 
    name description
  end
  
  # GROUP modes
  PUBLIC = 0
  PRIVATE = 1
  HIDDEN = 2
  
  class << self

    # Return not hidden groups
    def not_hidden(page = 1)
      paginate(:all, :page => page,
                     :per_page => RASTER_PER_PAGE,
                     :conditions => ["mode = ? OR mode = ?", PUBLIC,PRIVATE],
                     :order => "name ASC")
    end
  end
  
  def public?
    self.mode == PUBLIC
  end
  
  def private?
    self.mode == PRIVATE
  end
  
  def hidden?
    self.mode == HIDDEN
  end
  
  def owner?(person)
    self.owner == person
  end
  
  def has_invited?(person)
    Membership.invited?(person,self)
  end
 
  def is_viewable?(person)
   self.public? or self.private? or person.admin? or 
          self.owner?(person) or self.has_invited?(person) or
          (self.hidden? and self.people.include?(person))
  end

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
    photo.nil? ? "/images/g_default.png" : photo.public_filename
  end

  def thumbnail
    photo.nil? ? "/images/g_default_thumbnail.png" : photo.public_filename(:thumbnail)
  end

  def icon
    photo.nil? ? "/images/g_default_icon.png" : photo.public_filename(:icon)
  end

  def bounded_icon
    photo.nil? ? "/images/g_default_icon.png" : photo.public_filename(:bounded_icon)
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

  def create_owner_membership
    mem = Membership.new( :status => Membership::PENDING )
    mem.person = self.owner 
    mem.group = self
    mem.save
    Membership.accept(mem.person,mem.group)
  end

  def log_activity
    if not self.hidden?
      activity = Activity.create!(:item => self, :person => Person.find(self.person_id))
      add_activities(:activity => activity, :person => Person.find(self.person_id))
    end
  end
  
end
