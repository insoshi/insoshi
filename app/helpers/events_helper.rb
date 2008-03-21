module EventsHelper

  # Given an event, return a message for the feed for the event's class.
  def feed_message(event)
    person = event.person
    # Switch on the class.to_s.  (The class itself is long & complicated.)
    case event.class.to_s
    when "BlogPostEvent"
      blog = event.post.blog
      view_blog = link_to("View #{person.name}'s blog", blog)
      %(#{person_link(person)} made a blog post titled
        #{post_link(blog, event.post)}.<br /> #{view_blog})
    when "BlogPostCommentEvent"
      post = event.comment.post
      blog = post.blog
      %(#{person_link(person)} made a comment to
         #{someones(blog.person)} blog post #{post_link(blog, post)}.)
    when "ConnectionEvent"
      %(#{person_link(person)} and #{person_link(event.conn.contact)}
        have connected.)
    when "ForumPostEvent"
      post = event.post
      %(#{person_link(person)} made a post on the forum topic
        #{topic_link(post.topic)}.)
    when "PersonEvent"
      %(#{person_link(person)} joined the network!)
    when "TopicEvent"
      %(#{person_link(person)} created the new discussion topic
              #{topic_link(event.topic)}.)
    when "WallCommentEvent"
      %(#{person_link(event.comment.commenter)} commented on #{wall(person)})
    else
      raise "Invalid event type"
    end
  end
  
  def minifeed_message(event)
    person = event.person
    case event.class.to_s
    when "BlogPostEvent"
      blog = event.post.blog
      post = event.post
      %(#{person_link(person)} made a
        #{post_link("new blog post", blog, post)})
    when "BlogPostCommentEvent"
      post = event.comment.post
      %(#{person_link(person)} made a comment on #{someones(post.blog.person)} 
        #{post_link("blog post", post.blog, post)})
    when "ConnectionEvent"
      %(#{person_link(person)} and #{person_link(event.conn.contact)}
        have connected.)
    when "ForumPostEvent"
      topic = event.post.topic
      # TODO: deep link this to the post
      %(#{person_link(person)} made a #{topic_link("forum post", topic)}.)
    when "PersonEvent"
      %(#{person_link(person)} joined the network!)
    when "TopicEvent"
      %(#{person_link(person)} created a 
        #{topic_link("new discussion topic", event.topic)}.)
    when "WallCommentEvent"
      %(#{person_link(event.comment.commenter)} commented on #{wall(person)})
    else
      raise "Invalid event type"
    end
  end

  def someones(person, link = true)
    if link
      current_person?(person) ? "their own" : "#{person_link(person)}'s"
    else
      current_person?(person) ? "their own" : "#{person.name}'s"
    end
  end

  def person_link(text, person = nil)
    if person.nil?
      person = text
      text = person.name
    end
    link_to(text, person)
  end
  
  def post_link(text, blog, post = nil)
    if post.nil?
      post = blog
      blog = text
      text = post.title
    end
    link_to(text, blog_post_path(blog, post))
  end
  
  def topic_link(text, topic = nil)
    if topic.nil?
      topic = text
      text = topic.name
    end
    link_to(text, forum_topic_posts_path(topic.forum, topic))
  end

  # Return a link to the wall.
  def wall(person)
    link_to("#{someones(person, false)} wall",
            person_path(person, :anchor => "wall"))
  end
end
