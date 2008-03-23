module CommunicationsHelper
  def contact_links(requested_contacts)
    requested_contacts.map do |contact|
      conn = Connection.conn(current_person, contact)
      edit_connection_path(conn)
    end
  end
end
