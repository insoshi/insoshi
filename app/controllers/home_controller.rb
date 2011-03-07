class HomeController < ApplicationController
  skip_before_filter :require_activation
  
  def index
    if logged_in?
      redirect_to group_path(current_person.default_group)
    else
      @body = "blog"
      @posts = FeedPost.paginate(:all, :page => params[:page], :order => 'date_published DESC')
      @top_level_categories = Category.find(:all, :conditions => "parent_id is NULL").sort_by {|a| a.name}
      @categories = Category.find(:all).sort_by { |a| a.long_name }
    end    
  end

  def show
    @post = FeedPost.find(params[:id])
  end

end
