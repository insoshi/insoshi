module SearchesHelper
  
  # Return the model to be searched based on params.
  def search_model
    return "Person"    if params[:controller] == "home"
    return "ForumPost" unless params[:forum_id].nil?
    params[:model] || params[:controller].classify
  end
  
  # Return the partial (including path) for the given object.
  # partial can also accept an array of objects.
  def partial(object)
    object = object.first if object.is_a?(Array)
    klass = object.class.to_s
    case klass
    when "Person"
      'people/person'
    when "Topic"
      'topics/topic'
    end
  end
end
