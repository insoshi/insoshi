class HomeController < ApplicationController
  skip_before_filter :require_activation
  
  def index
    @topics = Topic.find_recent
    @members = Person.find_recent
    if logged_in?
      @body = "home"
      @person = current_person
      @reqs = current_person.current_and_active_reqs
      @bids = current_person.current_and_active_bids
      @requested_memberships = current_person.requested_memberships
      @invitations = current_person.invitations
    else
      @body = "blog"
      @posts = FeedPost.find(:all).paginate(:page => params[:page])
    end    
  end

  def refreshblog
    FeedPost.update_posts
    flash[:notice] = "Blog updated."
    redirect_to '/home' 
  end
end
