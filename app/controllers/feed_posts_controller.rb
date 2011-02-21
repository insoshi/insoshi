class FeedPostsController < ApplicationController
  before_filter :login_required, :admin_required
  def refresh_blog
    new_posts_count = FeedPost.update_posts
    if nil == new_posts_count
      flash[:error] = t('error_blog_update')
    else
      flash[:notice] = t('notice_blog_updated') + " #{new_posts_count} " + t('notice_entries')
    end
    redirect_to '/admin/feed_posts' 
  end
end
