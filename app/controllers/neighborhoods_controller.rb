class NeighborhoodsController < ApplicationController

  before_filter :login_required

  def show
    @neighborhood = Neighborhood.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
