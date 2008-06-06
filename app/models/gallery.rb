class Gallery < ActiveRecord::Base
  include ActivityLogger
  belongs_to :person
  has_many :photos, :dependent => :destroy
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  

  validates_length_of :title, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 1000, :allow_nil => true
  validates_presence_of :person_id
  
  after_create :log_activity

  
  def self.per_page
    5
  end
  

  def primary_photo
    if !self.primary_photo_id.nil?
      Photo.find(self.primary_photo_id)
    else
      nil
    end
  end
  
  def primary_photo=(photo)
    self.primary_photo_id = photo.id
  end
  
  def primary_photo_url
    primary_photo.nil? ? "default.png" : primary_photo.public_filename
  end

  def thumbnail_url
    primary_photo.nil? ? "default_thumbnail.png" : primary_photo.public_filename(:thumbnail)
  end

  def icon_url
    primary_photo.nil? ? "default_icon.png" : primary_photo.public_filename(:icon)
  end

  def bounded_icon_url
    primary_photo.nil? ? "default_icon.png" : primary_photo.public_filename(:bounded_icon)
  end
  
  def log_activity
    activity = Activity.create!(:item => self, :person => self.person)
    add_activities(:activity => activity, :person => self.person)
  end
  
end
