module ForumsHelper
  def forum_name(forum)
    forum.name.nil? ? "Forum ##{forum.id}" : forum.name
  end
end
