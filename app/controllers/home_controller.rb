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

  def refreshblog
    new_posts_count = FeedPost.update_posts
    if nil == new_posts_count
      flash[:error] = t('error_blog_update')
    else
      flash[:notice] = t('notice_blog_updated') + " #{new_posts_count} " + t('notice_entries')
    end
    redirect_to '/' 
  end
end
