class SearchesController < ApplicationController

  def index
    model = params[:model].constantize
    @results = model.search(params[:q], :page => params[:page])
  end
end
