class ActivitySweeper < ActionController::Caching::Sweeper
  observe Activity
  
  def after_create(activity)
    clear_cache
  end
  
  def after_destroy(activity)
    clear_cache
  end
  
  private
  
    def clear_cache
      logger.info "cache sweep"
      expire_fragment(:controller => "home", :action => "index",
                      :part => "feed")
    end
end