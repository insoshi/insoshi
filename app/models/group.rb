class Group < ActiveRecord::Base
  include ActivityLogger
  
  validates_presence_of :name, :person_id
  attr_protected :mandatory

  has_one :forum
  has_many :reqs, :conditions => "biddable IS true", :order => "created_at DESC"
  has_many :offers, :order => "created_at DESC"
  has_many :photos, :dependent => :destroy, :order => "created_at"
  has_many :exchanges, :order => "created_at DESC"
  has_many :memberships, :dependent => :destroy
  has_many :people, :through => :memberships, 
    :conditions => "status = 0", :order => "name DESC"
  has_many :pending_request, :through => :memberships, :source => "person",
    :conditions => "status = 2", :order => "name DESC"
  
  belongs_to :owner, :class_name => "Person", :foreign_key => "person_id"
  
  has_many :activities, :foreign_key => "item_id", :conditions => "item_type = 'Group'", :dependent => :destroy

  validates_uniqueness_of :name
  validates_uniqueness_of :unit, :allow_nil => true
  validates_uniqueness_of :asset, :allow_nil => true
  validates_format_of :asset, :with => /^[-\.a-z0-9]+$/i, :allow_blank => true
  after_create :create_owner_membership
  after_create :create_forum
  after_create :log_activity
  before_update :update_member_credit_limits
  
  index do 
    name description
  end
  
  # GROUP modes
  PUBLIC = 0
  PRIVATE = 1
  
  class << self

    def name_sorted_and_paginated(page = 1)
      paginate(:all, :page => page,
                     :per_page => RASTER_PER_PAGE,
                     :order => "name ASC")
    end
  end

  def admins
    memberships.with_role('admin').map {|m| m.person}
  end

  def public?
    self.mode == PUBLIC
  end
  
  def private?
    self.mode == PRIVATE
  end
  
  def owner?(person)
    self.owner == person
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

  def validate
    unless new_record?
      if asset_changed?
        unless asset_was.blank?
          errors.add(:asset, "cannot be changed unless it is empty")
        end
      end
    end
  end

  def create_owner_membership
    mem = Membership.new( :status => Membership::PENDING )
    mem.person = self.owner 
    mem.group = self
    mem.roles = ['admin']
    mem.save
    Membership.accept(mem.person,mem.group)
  end

  def update_member_credit_limits
    if default_credit_limit_changed?
      transaction do
        memberships.each do |m|
          m.account.update_attributes!(:credit_limit => default_credit_limit)
        end
      end
    end
  end

  def log_activity
    activity = Activity.create!(:item => self, :person => Person.find(self.person_id))
    add_activities(:activity => activity, :person => Person.find(self.person_id))
  end
  
end
