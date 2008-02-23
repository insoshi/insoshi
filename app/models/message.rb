class Message < Communication
  include ApplicationHelper

  attr_accessor :skip_send_mail
  
  MAX_CONTENT_LENGTH = 1600  # A reasonable limit on content length
  
  belongs_to :sender, :class_name => 'Person', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'Person',
                         :foreign_key => 'recipient_id'
  validates_presence_of :content
  validates_length_of :content, :maximum => MAX_CONTENT_LENGTH

  
  # after_create :update_recipient_last_contacted_at,
  #              :save_recipient, :set_replied_to, :send_receipt_reminder

  attr_accessor :reply, :parent
  
  def parent
    @parent ||= Message.find(parent_id)
  end

  # # Put the message in the trash for the given person.
  # def trash(person, time=Time.now)
  #   case person
  #   when sender
  #     self.sender_deleted_at = time
  #   when recipient
  #     self.recipient_deleted_at = time
  #   else
  #     # Given our controller before filters, this should never happen...
  #     false
  #   end
  #   save!
  # end
  # 
  # # Move the message back to the inbox.
  # def untrash(user)
  #   return false unless trashed?(user)
  #   trash(user, nil)
  # end
  # 
  # Return true if the message has been trashed.
  def trashed?(person)
    case person
    when sender
      !sender_deleted_at.nil? and sender_deleted_at > Person::TRASH_TIME_AGO
    when recipient
      !recipient_deleted_at.nil? and recipient_deleted_at > Person::TRASH_TIME_AGO
    end
  end
  # 
  # # Return true if the message is a reply to a previous message.
  # def reply?
  #   !hashed_parent_id.nil?
  # end
  # 
  # Return true if the message has been replied to.
  def replied_to?
    !replied_at.nil?
  end
  
  # Possibly mark a message as read.
  def read(time=Time.now)
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
      MessageReceiptMailer.deliver_reminder(self) unless @skip_send_mail
    end
end
