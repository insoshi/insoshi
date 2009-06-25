class HomeController < ApplicationController
  skip_before_filter :require_activation
  
  def index
    @body = "home"
    @topics = Topic.find_recent
    @members = Person.find_recent
    if logged_in?
      @person = current_person
      @feed = current_person.feed
      @some_contacts = current_person.some_contacts
      @requested_contacts = current_person.requested_contacts
      @requested_memberships = current_person.requested_memberships
      @invitations = current_person.invitations
    else
      @feed = Activity.global_feed
    end    
    respond_to do |format|
      format.html
    end  
  end
end
