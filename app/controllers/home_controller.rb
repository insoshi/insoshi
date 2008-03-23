class HomeController < ApplicationController
  
  before_filter :login_required
  
  def index
    
    @feed = current_person.feed
    
    @topics = Topic.find_recent
    @members = Person.find_recent
    @contacts = current_person.some_contacts
    @requested_contacts = current_person.requested_contacts
    
    respond_to do |format|
      format.html
    end
  end
end
