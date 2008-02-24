class Connection < ActiveRecord::Base
  belongs_to :person
  belongs_to :conn, :class_name => "Person",
                          :foreign_key => "connection_id"
  validates_presence_of :person_id, :connection_id
  
  # Return true if the persons are (possibly pending) conns.
  def self.exists?(person, conn)
    not find_by_person_id_and_connection_id(person, conn).nil?
  end
  
  # Make a pending conn request.
  def self.request(person, conn)
    unless person == conn or Connection.exists?(person, conn) 
      transaction do
        create(:person => person, :conn => conn, 
               :status => 'pending')
        create(:person => conn, :conn => person, 
               :status => 'requested')
      end
    end
  end
  
  # Accept a conn request.
  def self.accept(person, conn)
    transaction do
      accepted_at = Time.now
      accept_one_side(person, conn, accepted_at)
      accept_one_side(conn, person, accepted_at)
    end
  end
  
  # Delete a connship or cancel a pending request.
  def self.breakup(person, conn)
    transaction do
      destroy(find_by_person_id_and_connection_id(person, conn))
      destroy(find_by_person_id_and_connection_id(conn, person))
    end
  end
  
  private
  
  # Update the db with one side of an accepted connship request.
  def self.accept_one_side(person, conn, accepted_at)
    request = find_by_person_id_and_connection_id(person, conn)
    request.status = 'accepted'
    request.accepted_at = accepted_at
    request.save!
  end
end
