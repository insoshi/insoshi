class SearchesController < ApplicationController
  include ApplicationHelper

  before_filter :login_required

  def index
    
    redirect_to(home_url) and return if params[:q].nil?
    
    query = params[:q].strip
    model = strip_admin(params[:model])
    page  = params[:page] || 1

    unless %(Person Message ForumPost Req Offer Category Group).include?(model)
      flash[:error] = t('error_invalid_search')
      redirect_to home_url and return
    end

    if query.blank?
      @results,@page_results = []
    else
      klass = model.constantize
      @results = klass.search(query).all
      @page_results = @results.paginate(:page=> page, :per_page => 10)
    end
  end
  
  private
    
    # Strip off "Admin::" from the model name.
    # This is needed for, e.g., searches in the admin view
    def strip_admin(model)
      model.split("::").last
    end
end
