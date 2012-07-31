class FeedPostSweeper < ActionController::Caching::Sweeper
  observe FeedPost
  
  def after_create(feed_post)
    clear_cache
  end
  
  def after_update(feed_post)
    clear_cache
  end
  
  def after_destroy(feed_post)
    clear_cache
  end
  
  private
  
  def clear_cache
    #logger.info "cache sweep" # Causes heroku exception
    # for now, just clear everything
    Rails.cache.clear
  end
end
