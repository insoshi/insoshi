class SearchesController < ApplicationController
  include ApplicationHelper

  before_filter :login_required

  def index
    query = params[:q].strip
    model = strip_admin(params[:model])
    page  = params[:page] || 1

    unless %(Person Message ForumPost).include?(model)
      flash[:error] = "Invalid search"
      redirect_to home_url and return
    end

    if query.blank?
      @results = [].paginate
    else
      filters = {}
      if model == "Person" and current_person.admin?
        # Find all people, including deactivated and email unverified.
        model = "AllPerson"
      elsif model == "Message"
        filters['recipient_id'] = current_person.id
      end
      @search = Ultrasphinx::Search.new(:query => query, 
                                        :filters => filters,
                                        :page => page,
                                        :class_names => model)
      @search.run
      @results = @search.results
    end
  end
  
  private
    
    # Strip off "Admin::" from the model name.
    # This is needed for, e.g., searches in the admin view
    def strip_admin(model)
      model.split("::").last
    end
end
