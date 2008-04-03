class SearchesController < ApplicationController

  def index
    model = params[:model]
    @results = model.constantize.search(params)
    if model == "ForumPost" and @results
      # Cosolidate the topics, eliminating duplicates.
      @results = @results.map(&:topic).uniq.paginate
    end
  end
end
