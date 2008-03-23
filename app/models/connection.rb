# == Schema Information
# Schema version: 12
#
# Table name: connections
#
#  id          :integer(11)     not null, primary key
#  person_id   :integer(11)     
#  contact_id  :integer(11)     
#  status      :integer(11)     
#  accepted_at :datetime        
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Connection < ActiveRecord::Base
  belongs_to :person
  belongs_to :contact, :class_name => "Person", :foreign_key => "contact_id"
  
  validates_presence_of :person_id, :contact_id
  
  # Status codes.
  ACCEPTED  = 0
  REQUESTED = 1
  PENDING   = 2
  
  # Accept a connection request (instance method).
  # Each connection is really two rows, so delegate this method
  # to Connection.accept to wrap the whole thing in a transaction.
  def accept
    Connection.accept(person_id, contact_id)
  end
  
  def breakup
    Connection.breakup(person_id, contact_id)
  end
  
  class << self
  
    # Return true if the persons are (possibly pending) connections.
    def exists?(person, contact)
      not conn(person, contact).nil?
    end
  
    # Make a pending connection request.
    def request(person, contact, mail = EMAIL_NOTIFICATIONS)
      if person == contact or Connection.exists?(person, contact)
        false
      else
        transaction do
          create(:person => person, :contact => contact, :status => PENDING)
          create(:person => contact, :contact => person, :status => REQUESTED)
        end
        PersonMailer.deliver_connection_request(person, contact) if mail
        true
      end
    end
  
    # Accept a connection request.
    def accept(person, contact)
      transaction do
        accepted_at = Time.now
        accept_one_side(person, contact, accepted_at)
        accept_one_side(contact, person, accepted_at)
        # Log a connection event.
        # pid = person.is_a?(Person) ? person.id : person
        # cid = conn(person, contact).id
        # Event.create!(:item => conn(person, contact))
      end
    end
  
    # Delete a connection or cancel a pending request.
    def breakup(person, contact)
      transaction do
        destroy(conn(person, contact))
        destroy(conn(contact, person))
      end
    end
  
    # Return a connection based on the person and contact.
    def conn(person, contact)
      find_by_person_id_and_contact_id(person, contact)
    end
  end
  
  private
  
  # Update the db with one side of an accepted connection request.
  def self.accept_one_side(person, contact, accepted_at)
    conn(person, contact).update_attributes!(:status      => ACCEPTED,
                                             :accepted_at => accepted_at)
  end
end
