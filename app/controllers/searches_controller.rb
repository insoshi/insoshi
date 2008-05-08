class SearchesController < ApplicationController

  def index
    redirect_to home_url and return if params[:model].nil?
    model = params[:model]
    if model == "Message"
      options = params.merge(:recipient => current_person)
    else
      options = params
    end
    @results = model.constantize.search(options)
    if model == "ForumPost" and @results
      # Consolidate the topics, eliminating duplicates.
      # TODO: do this in the Topic model.  This will probably require some
      #       search-engine specific hacking, so defer to the time when we're
      #       ready to switch to Sphinx.
      @results = @results.map(&:topic).uniq.paginate
    end
  end
end
