module EventsHelper

  # Given an event, return a message for the feed for the event's class.
  def feed_message(event)
    person = event.person
    # Switch on the class.to_s.  (The class itself is long & complicated.)
    case event.class.to_s
    when "BlogPostEvent"
      blog = event.post.blog
      view_blog = link_to("View #{person.name}'s blog", blog)
      msg = %(#{person_link(person)} made a blog post titled
              #{post_link(blog, event.post)}.
              <br /> #{view_blog})
    when "BlogPostCommentEvent"
      post = event.comment.post
      blog = post.blog
      msg = %(#{person_link(person)} made a comment to
              #{someones(blog.person)} blog post #{post_link(blog, post)}.)
    when "ConnectionEvent"
      msg = %(#{person_link(person)} and #{person_link(event.conn.contact)}
              have connected.)
    when "ForumPostEvent"
      msg = %(#{person_link(person)} made a post on the forum topic
              #{topic_link(event.post.topic)}.)
    when "PersonEvent"
      msg = %(#{person_link(person)} joined the network!)
    when "TopicEvent"
      msg = %(#{person_link(person)} created the new discussion topic
              #{topic_link(event.topic)}.)
    when "WallCommentEvent"
      # TODO: link this to the wall with a #wall or something.
      a_wall = link_to("#{someones(person)} wall", person)
      msg = %(#{person_link(event.comment.commenter)} commented on #{a_wall})
    else
      raise "Invalid event type"
    end
  end
  
  def minifeed_message(event)
    person = event.person
    case event.class.to_s
    when "BlogPostEvent"
      blog = event.post.blog
      msg = %(#{person_link(person)} made a 
              #{link_to "new blog post", blog_post_path(blog, event.post)})
    when "BlogPostCommentEvent"
      post = event.comment.post
      blog = post.blog
      msg = %(#{person_link(person)} made a comment on
              #{someones(blog.person)} 
              #{link_to "blog post", blog_post_path(blog, post)})
    when "ConnectionEvent"
      msg = %(#{person_link(person)} and #{person_link(event.conn.contact)}
              have connected.)
    when "ForumPostEvent"
      topic = event.post.topic
      msg = %(#{person_link(person)} made a 
              #{link_to "forum post", forum_topic_posts_path(topic.forum, topic)}.)
    when "PersonEvent"
      msg = %(#{person_link(person)} joined the network!)
    when "TopicEvent"
      topic = event.topic
      msg = %(#{person_link(person)} created a 
              #{link_to "new discussion topic", forum_topic_posts_path(topic.forum, topic)}.)
    when "WallCommentEvent"
      # TODO: link this to the wall with a #wall or something.
      a_wall = link_to("#{someones(person)} wall", person)
      msg = %(#{person_link(event.comment.commenter)} commented on #{a_wall})
    else
      raise "Invalid event type"
    end
  end

  def someones(person)
    current_person?(person) ? "their own" : "#{person_link(person)}'s"
  end

  def person_link(person)
    link_to(person.name, person)
  end
  
  def post_link(blog, post)
    link_to(post.title, blog_post_path(blog, post))
  end
  
  def topic_link(topic)
    link_to(topic.name, forum_topic_posts_path(topic.forum, topic))
  end
end
