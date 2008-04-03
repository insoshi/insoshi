module SearchesHelper
  def search_model
    return "Person" unless params.nil?
    return "BlogPost" unless params[:blog_id].nil?
    return "ForumPost" unless params[:forum_id].nil?
    params[:model] || params[:controller].classify
  end
end
