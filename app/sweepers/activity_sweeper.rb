class ActivitySweeper < ActionController::Caching::Sweeper
  observe Activity
  
  def after_create(activity)
    logger.info "cache sweep"
    expire_fragment(:controller => "home", :action => "index", :part => "feed")
  end
end