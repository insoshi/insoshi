atom_feed do |feed|
  feed.title(app_name + " Forum Topics")
  feed.updated(@forum.topics.first.created_at)

  for topic in @forum.topics
    feed.entry(topic, :url => forum_topic_url(@forum, topic.id)) do |entry|
      entry.title(topic.name)
      firstBody = (topic.forum_posts_count > 0) ? topic.posts.first.body : ''
      bdy = 'Posts in topic: ' + topic.forum_posts_count.to_s + '<br /><br />' + firstBody
      entry.content(bdy, :type => 'html')

      entry.author do |author|
        author.name(topic.person.name)
      end
    end
  end
end