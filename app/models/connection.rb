# == Schema Information
# Schema version: 9
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
  belongs_to :contact, :class_name => "Person",
                          :foreign_key => "contact_id"
  validates_presence_of :person_id, :contact_id
  
  # Status codes.
  ACCEPTED  = 0
  REQUESTED = 1
  PENDING   = 2
  
  # Return true if the persons are (possibly pending) connections.
  def self.exists?(person, contact)
    not find_by_person_id_and_contact_id(person, contact).nil?
  end
  
  # Make a pending connection request.
  def self.request(person, contact, mail = true)
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
  def self.accept(person, contact)
    transaction do
      accepted_at = Time.now
      accept_one_side(person, contact, accepted_at)
      accept_one_side(contact, person, accepted_at)
    end
  end
  
  # Delete a connection or cancel a pending request.
  def self.breakup(person, contact)
    transaction do
      destroy(find_by_person_id_and_contact_id(person, contact))
      destroy(find_by_person_id_and_contact_id(contact, person))
    end
  end
  
  private
  
  # Update the db with one side of an accepted connection request.
  def self.accept_one_side(person, contact, accepted_at)
    request = find_by_person_id_and_contact_id(person, contact)
    request.status = ACCEPTED
    request.accepted_at = accepted_at
    request.save!
  end
end
