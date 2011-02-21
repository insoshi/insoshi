class HomeController < ApplicationController
  skip_before_filter :require_activation
  
  def index
    if logged_in?
      redirect_to group_path(current_person.default_group)
    else
      @body = "blog"
      @posts = FeedPost.paginate(:all, :page => params[:page], :order => 'date_published DESC')
    end    
  end

  def show
    @post = FeedPost.find(params[:id])
  end

end
