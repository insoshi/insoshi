class SearchesController < ApplicationController

  def index
    model = params[:model]
    @results = model.constantize.search(params)
    if model == "ForumPost" and @results
      # Cosolidate the topics, eliminating duplicates.
      # TODO: do this in the Topic model.  This will probably require some
      #       search-engine specific hacking, so defer to the time when we're
      #       ready to switch to Sphinx.
      @results = @results.map(&:topic).uniq.paginate
    end
  end
end
