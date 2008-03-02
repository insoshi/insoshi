class HomeController < ApplicationController
  
  before_filter :login_required
  
  def index
    # This is a stub for the real feed.
    # TODO: make a real feed :-)
    @mary = Person.find_by_email("mary@michaelhartl.com")
    @michael = Person.find_by_email("michael@michaelhartl.com")
    @linda = Person.find_by_email("linda@michaelhartl.com")
    
    @topics = Topic.find(:all, :order => "created_at DESC", :limit => 6)
    @members = Person.find(:all, :order => "people.created_at DESC",
                           :limit => 8, :include => :photos)
    respond_to do |format|
      format.html
    end
  end
end
