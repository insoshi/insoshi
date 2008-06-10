atom_feed do |feed|
  feed.title(app_name + " Forum - Topic " + @topic.name)
  feed.updated(@topic.posts.first.created_at)

  for post in @topic.posts
    feed.entry(post, :url => forum_topic_posts_url(@forum, @topic)) do |entry|
      entry.title(@topic.name + ' - Comment ' + post.id.to_s)
      entry.content(post.body, :type => 'html')

      entry.author do |author|
        author.name(post.person.name)
      end
    end
  end
end