module ForumsHelper
  def forum_name(forum)
    forum.name.nil? || forum.name.blank? ? "Forum ##{forum.id}" : forum.name
  end
end
