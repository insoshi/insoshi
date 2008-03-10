class HomeController < ApplicationController
  
  before_filter :login_required
  
  def index
    
    @feed = Event.find(:all).shuffle[(0...5)]
    
    @topics = Topic.find(:all, :order => "created_at DESC", :limit => 6)
    @members = Person.find(:all, :order => "people.created_at DESC",
                           :include => :photos, :limit => 8)
    @contacts = current_person.contacts[(0...11)]
    @requested_contacts = current_person.requested_contacts[(0...8)]
    @requested_contact_links = @requested_contacts.map do |p|
                                 conn = Connection.conn(current_person, p)
                                 edit_connection_path(conn)
                               end
    respond_to do |format|
      format.html
    end
  end
end
