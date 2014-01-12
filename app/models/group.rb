require 'texticle/searchable'

class Group < ActiveRecord::Base
  include ActivityLogger
  extend PreferencesHelper
  
  validates_presence_of :name, :person_id

  attr_accessible :name, :description, :mode, :unit, :adhoc_currency, :default_credit_limit
  attr_accessible :asset, :private_txns, :enable_forum, :display_balance, :display_earned, :display_paid
  attr_accessible :default_roles

  has_one :forum
  has_one :privacy_setting
  has_many :reqs, :conditions => ["biddable = ?",true], :order => "created_at DESC"
  has_many :offers, :order => "created_at DESC"
  has_many :photos, :as => :photoable, :dependent => :destroy, :order => "created_at"
  has_many :exchanges, :order => "created_at DESC"
  has_many :exchange_and_fees, :order => "created_at DESC"
  has_many :memberships, :dependent => :destroy
  has_many :accounts, :dependent => :destroy
  has_many :people, :through => :memberships, 
    :conditions => "status = 0", :order => "name DESC"
  has_many :pending_request, :through => :memberships, :source => "person",
    :conditions => "status = 2", :order => "name DESC"
  
  belongs_to :owner, :class_name => "Person", :foreign_key => "person_id"
  
  has_many :activities, :as => :item, :dependent => :destroy

  validates_uniqueness_of :name
  validates_uniqueness_of :unit, :allow_nil => true
  validates_uniqueness_of :asset, :allow_nil => true
  validates_format_of :asset, :with => /^[-\.a-z0-9_]+$/i, :allow_blank => true
  validate :changing_asset_name_only_allowed_if_empty
  after_create :create_owner_membership
  after_create :create_forum
  after_create :create_privacy_setting
  after_create :log_activity
  before_update :update_member_credit_limits
  
  extend Searchable(:name, :description)
  
  # GROUP modes
  PUBLIC = 0
  PRIVATE = 1
  
  def get_groups_modes
    modes = []
    modes << ["Public",PUBLIC]
    modes << ["Membership approval required",PRIVATE] unless default_group?
    return modes
  end

  def default_group?
    id == Group.global_prefs.default_group_id
  end

  def default_roles=(roles)
    self.roles_mask = (roles & Membership::ROLES).map { |r| 2**Membership::ROLES.index(r) }.sum
  end

  def default_roles
    Membership::ROLES.reject do |r|
      ((roles_mask || 0) & 2**Membership::ROLES.index(r)).zero?
    end
  end
  
  class << self

    def name_sorted_and_paginated(page = 1)
      paginate(:page => page,
               :per_page => RASTER_PER_PAGE,
               :order => "name ASC")
    end

    def by_opentransact(asset)
      Group.find_by_asset(asset)
    end
  end

  def opentransact?
    !asset.nil?
  end

  def admins
    admins = memberships.with_role('admin').map {|m| m.person}
    admins << owner if admins.empty?
    admins
  end

  def reserves
    accounts.where(reserve: true).map {|a| a.person}
  end

  def sum_reserves
    accounts.where(reserve: true).map(&:reserve_percent).inject(:+) || 0
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
 
  def authorized_to_view_reqs?(person)
    privacy_setting.viewable_reqs? or Membership.exist?(person, self)
  end

  def authorized_to_view_offers?(person)
    privacy_setting.viewable_offers? or Membership.exist?(person, self)
  end

  def authorized_to_view_forum?(person)
    privacy_setting.viewable_forum? or Membership.exist?(person, self)
  end

  def authorized_to_view_members?(person)
    privacy_setting.viewable_members? or Membership.exist?(person, self)
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
    photo.nil? ? Preference.group_image : photo.picture_url
  end

  def thumbnail
    photo.nil? ? Preference.group_image(:thumbnail) : photo.picture_url(:thumbnail)
  end

  def icon
    photo.nil? ? Preference.group_image(:icon) : photo.picture_url(:icon)
  end

  def bounded_icon
    photo.nil? ? Preference.group_image(:icon) : photo.picture_url(:icon)
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

  def changing_asset_name_only_allowed_if_empty
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
