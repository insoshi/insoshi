module SearchesHelper
  
  # Return the model to be searched based on params.
  def search_model
    return "Req"       if params[:controller] =~ /home/
    return "Req"       if params[:controller] =~ /reqs/
    return "Offer"     if params[:controller] =~ /offers/
    return "Category"  if params[:controller] =~ /categories/
    return "ForumPost" if params[:controller] =~ /forums/
    return "Group"     if params[:controller] =~ /groups/ or params[:action] =~ /groups/
    return "Person"    if params[:controller] =~ /people/ # Needs to be last
    params[:model] || params[:controller].classify
  end
  
  def search_type
    if params[:controller] == "forums" or params[:model] == "ForumPost"
      t('searches.type.forums')
    elsif params[:controller] == "messages" or params[:model] == "Message"
      t('searches.type.messages')
    elsif params[:controller].include?("groups") or params[:model] == "Group" or params[:action].include?("groups")
      t('searches.type.groups')
    elsif params[:controller] == "people" or params[:model] == "Person"
      t('searches.type.people')
    elsif params[:controller] == "categories" or params[:model] == "Category"
      t('searches.type.categories')
    elsif params[:controller] == "offers" or params[:model] == "Offer"
      t('searches.type.offers')
    else
      t('searches.type.reqs')
    end
  end
  
  # Return the partial (including path) for the given object.
  # partial can also accept an array of objects (of the same type).
  def partial(object)
    object = object.first if object.is_a?(Array)
    klass = object.class.to_s
    case klass
    when "ForumPost"
      dir  = "topics" 
      part = "search_result"
    when "AllPerson"
      dir  = 'people'
      part = 'person'
    else
      dir  = klass.tableize  # E.g., 'Person' becomes 'people'
      part = dir.singularize # E.g., 'people' becomes 'person'
    end
    admin_search? ? "admin/#{dir}/#{part}" : "#{dir}/#{part}"
  end

  private
  
    def admin_search?
      params[:model] =~ /Admin/
    end
end
