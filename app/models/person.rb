class Person < ActiveRecord::Base

  if !test? or (test? and FERRET_IN_TESTS)
    acts_as_ferret :fields => [ :name, :description ]
  end
  
  MAX_EMAIL = MAX_PASSWORD = 40
  EMAIL_REGEX = /\A[A-Z0-9\._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}\z/i
  TEXT_LENGTH = 120 # truncation parameter for people listings
  NAME_LENGTH = 32
  DESCRIPTION_LENGTH = 2000
  TRASH_TIME_AGO = 1.month.ago
  SEARCH_LIMIT = 20
  SEARCH_PER_PAGE = 5
  MESSAGES_PER_PAGE = 5
  NUM_RECENT_MESSAGES = 4
  NUM_RECENTLY_VIEWED = 4
  
  has_many :photos, :dependent => :destroy, :order => 'created_at'
  # TODO: use with_options here
  has_many :_sent_messages,     :foreign_key => "sender_id",
                                :class_name => "Message",
                                :dependent => :destroy,
                                :conditions => "sender_deleted_at IS NULL",
                                :order => 'created_at DESC'
  has_many :_received_messages, :foreign_key => "recipient_id",
                                :class_name => "Message",
                                :dependent => :destroy,
                                :conditions => "recipient_deleted_at IS NULL",
                                :order => 'created_at DESC'
  attr_accessor :password, :sorted_photos
  attr_accessible :email, :password, :password_confirmation, :name,
                  :description
  
  validates_presence_of     :email
  validates_presence_of     :password,              :if => :password_required?
  validates_presence_of     :password_confirmation, :if => :password_required?
  validates_length_of       :password, :within => 4..MAX_PASSWORD,
                                       :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of       :email,    :within => 3..MAX_EMAIL
  validates_format_of       :email,                                    
                            :with => EMAIL_REGEX,                      
                            :message => "must be a valid email address"
  validates_uniqueness_of   :email
  
  before_save :downcase_email, :encrypt_password
  
  ## Class methods
  
  # People search using Ferret
  def self.search(query, options = {})
    return [].paginate if query.blank?
    limit = [total_hits(query), SEARCH_LIMIT].min
    paginate_by_contents(query, :page => options[:page],
                                :per_page => SEARCH_PER_PAGE,
                                :total_entries => limit)
  end
  
  ## Message methods

  def received_messages(page = 1)
    _received_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end  
  
  def sent_messages(page = 1)
    _sent_messages.paginate(:page => page, :per_page => MESSAGES_PER_PAGE)
  end
  
  def trashed_messages(page = 1)
    conditions = [%((sender_id = :person AND sender_deleted_at > :t) OR
                    (recipient_id = :person AND recipient_deleted_at > :t)),
                  { :person => id, :t => TRASH_TIME_AGO }]
    order = 'created_at DESC'
    trashed = Message.paginate(:all, :conditions => conditions,
                                     :order => order,
                                     :page => page,
                                     :per_page => MESSAGES_PER_PAGE)
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
    photo.nil? ? "default.png" : photo.public_filename
  end

  def thumbnail
    photo.nil? ? "default_thumbnail.png" : photo.public_filename(:thumbnail)
  end  

  def icon
    photo.nil? ? "default_icon.png" : photo.public_filename(:icon)
  end  
  
  # Return the photos ordered by primary first, then by created_at.
  # They are already ordered by created_at as per the has_many association.
  def sorted_photos
    # The call to partition ensures that the primary photo comes first.
    # photos.partition(&:primary) => [[primary], [other one, another one]]
    # flatten yields [primary, other one, another one]
    @sorted_photos ||= photos.partition(&:primary).flatten
  end
  
  ## Authentication methods
  
  # Authenticates a user by their email address and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_by_email(email.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def self.encrypt(password)
    Crypto::Key.from_file('rsa_key.pub').encrypt(password)
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password)
  end

  def decrypt(password)
    Crypto::Key.from_file('rsa_key').decrypt(password)
  end

  def authenticated?(password)
    unencrypted_password == password
  end
  
  def unencrypted_password
    # The gsub trickery is to unescape the key from the DB.
    decrypt(crypted_password.gsub(/\\n/, "\n"))
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.years
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    key = "#{email}--#{remember_token_expires_at}"
    self.remember_token = Digest::SHA1.hexdigest(key)
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected

    def downcase_email
      self.email = email.downcase
    end

    def encrypt_password
      return if password.blank?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
