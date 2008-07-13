class SearchesController < ApplicationController
  include ApplicationHelper

  before_filter :login_required

  def index
    query = params[:q].strip
    model = strip_admin(params[:model])
    # if query.blank?
    #   flash[:notice] = "No search results for '#{CGI.escapeHTML(query)}'."
    #   redirect_to :back and return
    # end
    if query.blank?
      @results = [].paginate
    else
      filters = {}
      if model == "Person" and not current_person.admin?
        # Filter out deactivated and email unverified users for non-admins.
        filters['deactivated']    = 0
        filters['email_verified'] = 1 if global_prefs.email_verifications?
      elsif model == "Message"
        filters['recipient_id'] = current_person.id
        filters['recipient_deleted_at'] = 0  # 0 is the same as NULL (!)
      end
      
      @search = Ultrasphinx::Search.new(:query => params[:q], 
      :filters => filters,
      :page => params[:page] || 1,
      :class_names => model
      )
      @search.run
      @results = @search.results
      # raise @results.first.deactivated.inspect
    end
    # redirect_to home_url and return if params[:model].nil?
    # if model == "Message"
    #   options = params.merge(:recipient => current_person)
    # else
    #   options = params
    # end
    # options[:all] = true if admin?
    # @results = model.constantize.search(options)
    # if model == "ForumPost" and @results
    #   # Consolidate the topics, eliminating duplicates.
    #   # TODO: do this in the Topic model.  This will probably require some
    #   #       search-engine specific hacking, so defer to the time when we're
    #   #       ready to switch to Sphinx.
    #   @results = @results.map(&:topic).uniq.paginate
    # end
  end
  
  private
    
    # Strip off "Admin::" from the model name.
    # This is needed for, e.g., searches in the admin view
    def strip_admin(model)
      model.split("::").last
    end
end
