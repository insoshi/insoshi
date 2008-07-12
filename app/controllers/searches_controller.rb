class SearchesController < ApplicationController
  include ApplicationHelper

  def index
    query = params[:q].strip
    # if query.blank?
    #   flash[:notice] = "No search results for '#{CGI.escapeHTML(query)}'."
    #   redirect_to :back and return
    # end
    if query.blank?
      @results = [].paginate
    else
      @search = Ultrasphinx::Search.new(:query => params[:q], 
      :filters => { 'deactivated' => 0 },
      :page => params[:page] || 1,
      :class_names => "Person"
      )
      @search.run
      @results = @search.results
      # raise @results.first.deactivated.inspect
    end
    # redirect_to home_url and return if params[:model].nil?
    # model = strip_admin(params[:model])
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
