require 'texticle/searchable'

class Person < ActiveRecord::Base
  include ActivityLogger
  extend PreferencesHelper

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders.const_get(ENV['CRYPTOPROVIDER'].to_sym) unless ENV['CRYPTOPROVIDER'].blank?
    c.openid_required_fields = ['http://axschema.org/contact/email',
      'http://axschema.org/namePerson/first',
      'http://axschema.org/namePerson/last',
      :fullname,
      :email
    ]
    c.perishable_token_valid_for = 48.hours
    c.maintain_sessions = false if Rails.env == "test"
  end

  #  attr_accessor :password, :verify_password, :new_password, :password_confirmation
  attr_accessor :sorted_photos, :accept_agreement
  attr_accessible *attribute_names, :as => :admin
  attr_accessible :address_ids, :as => :admin
  attr_accessible :password, :password_confirmation, :as => :admin
  attr_accessible :email, :password, :password_confirmation, :name
  attr_accessible :business_name, :legal_business_name, :business_type_id
  attr_accessible :title, :activity_status_id, :plan_type_id, :support_contact_id
  attr_accessible :description, :connection_notifications
  attr_accessible :message_notifications
  attr_accessible :category_ids, :address_ids, :neighborhood_ids
  attr_accessible :zipcode
  attr_accessible :phone, :phoneprivacy
  attr_accessible :accept_agreement
  attr_accessible :language, :time_zone, :date_style
  attr_accessible :openid_identifier
  attr_accessible :sponsor
  attr_accessible :broadcast_emails
  attr_accessible :web_site_url
  attr_accessible :org
  attr_accessible :posts_per_page

  extend Searchable(:name, :business_name, :description)

  MAX_PASSWORD = 40
  MAX_NAME = 40
  MAX_DESCRIPTION = 5000
  TRASH_TIME_AGO = 1.month
  MESSAGES_PER_PAGE = 5
  EXCHANGES_PER_PAGE = 10
  NUM_RECENT_MESSAGES = 3
  NUM_RECENT = 8
  FEED_SIZE = 10
  TIME_AGO_FOR_MOSTLY_ACTIVE = 12.months
  DEFAULT_ZIPCODE_STRING = '89001'
  # These constants should be methods, but I couldn't figure out how to use
  # methods in the has_many associations.  I hope you can do better.

  module Scopes

    def active
      if global_prefs.email_verifications
        where(:deactivated => false, :email_verified => true)
      else
        where(:deactivated => false)
      end
    end

    def mostly_active
      where("last_logged_in_at >= ?", TIME_AGO_FOR_MOSTLY_ACTIVE.ago)
    end

    def with_zipcode(z)
      includes(:addresses).where('addresses.zipcode_plus_4' => z)
    end

    def broadcast_email
      where :broadcast_emails => true
    end

    def connection_notifications
      where :connection_notifications => true
    end

    def by_first_letter
      order("first_letter ASC")
    end

    def by_name
      order("name ASC")
    end

    def by_newest
      order("created_at DESC")
    end

  end

  extend Scopes

  has_many :connections
  has_many :contacts, :through => :connections, :conditions => {"connections.status" => Connection::ACCEPTED}
  has_many :photos, :as => :photoable, :dependent => :destroy, :order => 'created_at'
  has_many :requested_contacts, :through => :connections, :source => :contact#, :conditions => REQUESTED_AND_ACTIVE

  with_options :dependent => :destroy, :order => 'created_at DESC' do |person|
    person.has_many :_sent_messages, :foreign_key => "sender_id",
    :conditions => "communications.sender_deleted_at IS NULL", :class_name => "Message"
    person.has_many :_received_messages, :foreign_key => "recipient_id",
    :conditions => "communications.recipient_deleted_at IS NULL", :class_name => "Message"
    person.has_many :_sent_exchanges, :foreign_key => "customer_id", :class_name => "Exchange"
    person.has_many :_received_exchanges, :foreign_key => "worker_id", :class_name => "Exchange"
  end

  has_many :exchanges, :foreign_key => "worker_id"
  has_many :feeds
  has_many :activities, :through => :feeds, :order => 'activities.created_at DESC',
  :limit => FEED_SIZE,
  :conditions => ["people.deactivated = ?", false],
  :include => :person

  #  has_many :page_views, :order => 'created_at DESC'

  has_many :own_groups, :class_name => "Group", :foreign_key => "person_id", :order => "name ASC"
  has_many :memberships
  has_many :groups, :through => :memberships, :source => :group, :conditions => "status = 0", :order => "name ASC"
  has_many :groups_not_hidden, :through => :memberships, :source => :group, :conditions => "status = 0 and mode != 2", :order => "name ASC"

  has_many :accounts
  has_many :addresses, :inverse_of => :person
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order => "authorized_at DESC", :include => [:client_application]

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :neighborhoods
  has_many :offers
  has_many :reqs
  has_many :bids
  has_many :invitations, :order => 'created_at DESC'
  belongs_to :default_group, :class_name => "Group", :foreign_key => "default_group_id"
  belongs_to :sponsor, :class_name => "Person", :foreign_key => "sponsor_id"
  belongs_to :support_contact, :class_name => "Person", :foreign_key => "support_contact_id"
  belongs_to :business_type
  belongs_to :activity_status
  belongs_to :plan_type

  validates :name, :presence => true, :length => { :maximum => MAX_NAME }
  validates :description, :length => { :maximum => MAX_DESCRIPTION }
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates :business_name, :length => { :maximum => 100 }, :presence => true, :if => lambda { |p| p.org }
  validates :legal_business_name, :length => { :maximum => 100 }
  validates :business_type, :presence => true, :if => lambda { |p| p.org }
  #  validates_presence_of     :password,              :if => :password_required?
  #  validates_presence_of     :password_confirmation, :if => :password_required?
  #  validates_length_of       :password, :within => 4..MAX_PASSWORD,
  #                                       :if => :password_required?
  #  validates_confirmation_of :password, :if => :password_required?

  #  validates_uniqueness_of   :identity_url, :allow_nil => true

  # XXX just doing jquery validation
  #validates_acceptance_of :accept_agreement, :accept => true, :message => "Please accept the agreement to complete registration", :on => :create

  before_create :check_config_for_deactivation
  before_create :set_language_and_default_group
  after_create :create_address
  after_create :join_mandatory_groups
  before_save :update_group_letter
  before_validation :prepare_email, :handle_nil_description
  #after_create :connect_to_admin

  before_update :set_old_description
  after_update :log_activity_description_changed
  before_destroy :destroy_activities, :destroy_feeds


  # Return the first admin created.
  # We suggest using this admin as the primary administrative contact.
  def Person.find_first_admin
    where(:admin => true).order(:created_at).first
  end

  def transactions
    txns_table = Transact.arel_table
    Transact.where(txns_table[:worker_id].eq(self.id).or(txns_table[:customer_id].eq(self.id))).order('created_at DESC')
  end

  # Display name based upon entity type
  def display_name
    org ? business_name : name
  end

  # Display name based upon entity type plus contact for business
  def display_name_and_contact
    org ? "#{business_name} (#{name})" : name
  end

  # Params for use in urls.
  # Profile urls have the form '/people/1-michael-hartl'.
  # This works automagically because Person.find(params[:id]) implicitly
  # converts params[:id] into an int, and in Ruby
  # '1-michael-hartl'.to_i == 1
  def to_param
    "#{id}-#{name.to_safe_uri}"
  end

  ## Feeds

  # Return a person-specific activity feed.
  def feed
    len = activities.length
    if len < FEED_SIZE
      # Mix in some global activities for smaller feeds.
      global = Activity.global_feed[0...(Activity::GLOBAL_FEED_SIZE-len)]
      (activities + global).uniq.sort_by { |a| a.created_at }.reverse
    else
      activities
    end
  end

  def recent_activity
    Activity.where(:person_id => self.id).order('created_at DESC').limit(FEED_SIZE)
  end

  ## For the home page...

  # Return some contacts for the home page.
  def some_contacts
    contacts[(0...12)]
  end

  def requested_memberships
    Membership.where(:status => 2, :group_id => own_group_ids)
  end

  # Contact links for the contact image raster.
  def requested_contact_links
    requested_contacts.map do |p|
      conn = Connection.conn(self, p)
      edit_connection_path(conn)
    end
  end

  ## Message methods

  def received_messages(page = 1, text = "")
    _received_messages.search_by(text).paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end

  def sent_messages(page = 1)
    _sent_messages.
    paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end

  ## Exchange methods

  def received_exchanges(page = 1)
    _received_exchanges.
    where(:group_id => nil).
    paginate(:page => page, :per_page => EXCHANGES_PER_PAGE)
  end

  def received_group_exchanges(group_id, page = 1)
    _received_exchanges.
    where(:group_id => group_id).
    paginate(:page => page, :per_page => EXCHANGES_PER_PAGE)
  end

  def sent_exchanges(page = 1)
    _sent_exchanges.
    paginate(:page => page, :per_page => EXCHANGES_PER_PAGE)
  end

  def sent_group_exchanges(group_id, page = 1)
    _sent_exchanges.
    where(:group_id => group_id).
    paginate(:page => page, :per_page => EXCHANGES_PER_PAGE)
  end

  def trashed_messages(page = 1)
    Message.
    where(%((sender_id = ? AND sender_deleted_at > ?) OR (recipient_id = ? AND recipient_deleted_at > ?)),
    id, TRASH_TIME_AGO.ago, id, TRASH_TIME_AGO.ago).
    order('created_at DESC').
    paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end

  def recent_messages
    Message.
    where(:recipient_id => id, :recipient_deleted_at => nil).
    order("created_at DESC").
    limit(NUM_RECENT_MESSAGES)
  end

  def has_unread_messages?
    Message.where(:recipient_id => id, :recipient_read_at => nil).exists?
  end

  def has_inbox_messages?
    Message.where(:recipient_id => id, :recipient_read_at => nil, :recipient_deleted_at => nil).exists?
  end

  def unread_messages_count
    Message.where(:recipient_id => id, :recipient_read_at => nil).count
  end

  def inbox_messages_count
    Message.where(:recipient_id => id, :recipient_read_at => nil, :recipient_deleted_at => nil).count
  end

  def formatted_categories
    categories_long_name('<br>')
  end

  # from Columbia
  def listed_categories
    categories_long_name(', ')
  end

  def categories_long_name(joiner = nil)
    l = categories.collect &:long_name
    joiner ? l.join(joiner) : l
  end

  def current_offers
    offers.where("expiration_date >= ?", DateTime.now).order('created_at DESC')
  end

  def current_and_active_reqs
    reqs.current.biddable.order('created_at DESC')
  end

  def current_and_active_bids
    bids.where("state != ? AND NOT (state = ? AND expiration_date < ?)", 'approved', 'offered', DateTime.now).order('created_at DESC')
  end

  def create_address
    if 0 == addresses.length
      # share address if this is an org
      addresses.create(:name => 'personal', :address_privacy => org, :primary => true, :zipcode_plus_4 => (zipcode.presence || DEFAULT_ZIPCODE_STRING))
    end
  end

  def set_language_and_default_group
    self.default_group_id = Person.global_prefs.default_group_id
    self.language = Person.global_prefs.locale
  end

  def join_mandatory_groups
    Group.where(:mandatory => true).each do |g|
      Membership.request(self, g, false)
    end
  end

  def address
    primary_address || addresses.first
  end

  def primary_address
    addresses.find_all_by_primary(true).first
  end

  def shared_addresses
    addresses.where(address_privacy: true)
  end

  ## Account helpers

  def account(group)
    accounts.where(:group_id => group.id).first
  end

  def notifications
    connection_notifications
  end

  def is?(role, group)
    mem = Membership.mem(self, group)
    mem && mem.is?(role)
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
    photo.nil? ? Preference.profile_image : photo.picture_url
  end

  def thumbnail
    photo.nil? ? Preference.profile_image(:thumbnail) : photo.picture_url(:thumbnail)
  end

  def icon
    photo.nil? ? Preference.profile_image(:icon) : photo.picture_url(:icon)
  end

  def bounded_icon
    photo.nil? ? Preference.profile_image(:icon) : photo.picture_url(:icon)
  end

  # Return the photos ordered by primary first, then by created_at.
  # They are already ordered by created_at as per the has_many association.
  def sorted_photos
    # The call to partition ensures that the primary photo comes first.
    # photos.partition(&:primary) => [[primary], [other one, another one]]
    # flatten yields [primary, other one, another one]
    @sorted_photos ||= photos.partition(&:primary).flatten
    #@sorted_photos ||= photos.order("(CASE WHEN primary THEN 1 WHEN primary IS NULL THEN 2 ELSE 3 END)")
  end

  def sorted_addresses
    @sorted_addresses ||= addresses.partition(&:primary).flatten
  end

  def change_password?(passwords)
    self.password_confirmation = passwords[:password_confirmation]
    unless passwords[:password] == password_confirmation
      errors.add(:password, "does not match confirmation")
      return false
    end
    self.password = passwords[:password]
    save
  end

  # Return true if the person is the last remaining active admin.
  def last_admin?
    num_admins = Person.where(:admin => true, :deactivated => false).count
    admin? and num_admins == 1
  end

  def active?
    not deactivated? and (Person.global_prefs.email_verifications? ? email_verified? : true)
  end

  # Return the common connections with the given person.
  def common_contacts_with(contact, page = 1)
    Person.
    active.
    joins(:connections).
    where("connections.contact_id" => [self.id, contact.id]).
    group("people.id having count(connections.*) = 2").
    paginate(:page => page, :per_page => RASTER_PER_PAGE)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    after_transaction { PersonMailerQueue.password_reset_instructions(self) }
  end

  def deliver_email_verification!
    reset_perishable_token!
    after_transaction { PersonMailerQueue.email_verification(self) }
  end

  protected

  def map_openid_registration(sreg_registration, ax_registration)
    unless sreg_registration.nil?
      self.email = sreg_registration['email'] if email.blank?
      self.name = sreg_registration['fullname'] if name.blank?
    end
    unless ax_registration.nil?
      self.email = ax_registration["http://axschema.org/contact/email"].first if email.blank?
      if name.blank?
        self.name = [ax_registration['http://axschema.org/namePerson/first'].first,
                     ax_registration['http://axschema.org/namePerson/last'].first].join(' ')
      end
    end
  end

  ## Callbacks

  # Prepare email for database insertion.
  def prepare_email
    self.email = email.downcase.strip if email
  end

  # Handle the case of a nil description.
  # Some databases (e.g., MySQL) don't allow default values for text fields.
  # By default, "blank" fields are really nil, which breaks certain
  # validations; e.g., nil.length raises an exception, which breaks
  # validates_length_of.  Fix this by setting the description to the empty
  # string if it's nil.
  def handle_nil_description
    self.description = "" unless description
  end

  def update_group_letter
    self.first_letter = display_name.mb_chars.first.upcase.to_s
  end

  def check_config_for_deactivation
    if Person.global_prefs.whitelist?
      self.deactivated = true
    end
  end

  def set_old_description
    p = Person.find(self)
    @old_description = p.description
  end

  def log_activity_description_changed
    unless @old_description == description or description.blank?
      add_activities(:item => self, :person => self)
    end
  end

  # Clear out all activities associated with this person.
  def destroy_activities
    Activity.where(:person_id => self.id).each &:destroy
  end

  def destroy_feeds
    Feed.where(:person_id => self.id).each &:destroy
  end

  ## Other private method(s)

  def password_required?
    true
    #(crypted_password.blank? && identity_url.nil?) || !password.blank? ||
    #!verify_password.nil?
  end

end
