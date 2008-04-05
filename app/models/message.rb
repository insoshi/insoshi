# == Schema Information
# Schema version: 15
#
# Table name: communications
#
#  id                   :integer         not null, primary key
#  subject              :string(255)     
#  content              :text            
#  parent_id            :string(255)     
#  sender_id            :integer         
#  recipient_id         :integer         
#  sender_deleted_at    :datetime        
#  sender_read_at       :datetime        
#  recipient_deleted_at :datetime        
#  recipient_read_at    :datetime        
#  replied_at           :datetime        
#  type                 :string(255)     
#  created_at           :datetime        
#  updated_at           :datetime        
#

class Message < Communication
  attr_accessor :reply, :parent, :skip_send_mail
  acts_as_ferret :fields => [ :subject, :content ] if search?
  
  MAX_CONTENT_LENGTH = MAX_TEXT_LENGTH
  SEARCH_LIMIT = 20
  SEARCH_PER_PAGE = 8
  
  belongs_to :sender, :class_name => 'Person', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'Person',
                         :foreign_key => 'recipient_id'
  validates_presence_of :subject, :content
  validates_length_of :subject, :maximum => SMALL_STRING_LENGTH
  validates_length_of :content, :maximum => MAX_CONTENT_LENGTH

  
  after_create :update_recipient_last_contacted_at,
               :save_recipient, :set_replied_to, :send_receipt_reminder
  
  class << self
    def search(options = {})
      query = options[:q]
      query = options[:q]
      return [].paginate if query.blank? or query == "*"
      # This is ineffecient.  We'll fix it when we move to Sphinx.
      conditions = ["recipient_id = ? AND recipient_deleted_at IS NULL",
                    options[:recipient]]
      # raise conditions.inspect
      results = find_by_contents(query, {}, :conditions => conditions)
      results[0...SEARCH_LIMIT].paginate(:page => options[:page],
                                         :per_page => SEARCH_PER_PAGE)
    end
    
  end
  
  def parent
    return @parent unless @parent.nil?
    return Message.find(parent_id) unless parent_id.nil?
  end
  
  def parent=(message)
    @parent = message
  end

  # Put the message in the trash for the given person.
  def trash(person, time=Time.now)
    case person
    when sender
      self.sender_deleted_at = time
    when recipient
      self.recipient_deleted_at = time
    else
      # Given our controller before filters, this should never happen...
      raise ArgumentError,  "Unauthorized person"
    end
    save!
  end
  
  # Move the message back to the inbox.
  def untrash(user)
    return false unless trashed?(user)
    trash(user, nil)
  end
  
  # Return true if the message has been trashed.
  def trashed?(person)
    case person
    when sender
      !sender_deleted_at.nil? and sender_deleted_at > Person::TRASH_TIME_AGO
    when recipient
      !recipient_deleted_at.nil? and recipient_deleted_at > Person::TRASH_TIME_AGO
    end
  end
  
  # Return true if the message is a reply to a previous message.
  def reply?
    !parent.nil? and correct_sender_recipient_pair?
  end
  
  # Return true if the sender/recipient pair is valid for a given parent.
  def correct_sender_recipient_pair?
    # People can send multiple replies to the same message, in which case
    # the recipient is the same as the parent recipient.
    # For most replies, the message recipient should be the parent sender.
    # We use Set to handle both cases uniformly.
    Set.new([sender, recipient]) == Set.new([parent.sender, parent.recipient])
  end
  
  # Return true if the message has been replied to.
  def replied_to?
    !replied_at.nil?
  end
  
  # Mark a message as read.
  def mark_as_read(time=Time.now)
    unless read?
      self.recipient_read_at = time
      save!
    end
  end
  
  # Return true if a message has been read.
  def read?
    !recipient_read_at.nil?
  end

  private
  
    # Mark the parent message as replied to the current message as a reply.
    def set_replied_to
      parent.update_attributes!(:replied_at => Time.now) if reply?
    end
    
    def update_recipient_last_contacted_at
      self.recipient.last_contacted_at = updated_at
    end
    
    def save_recipient
      self.recipient.save!
    end
    
    def send_receipt_reminder
      @skip_send_mail ||= !EMAIL_NOTIFICATIONS
      PersonMailer.deliver_message_notification(self) unless @skip_send_mail
    end
end
