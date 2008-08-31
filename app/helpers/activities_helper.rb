module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      view_blog = blog_link("View #{h person.name}'s blog", blog)
      %(#{person_link(person)} made a blog post titled
        #{post_link(blog, post)}.<br /> #{view_blog}.)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person_link(person)} made a comment to
           #{someones(blog.person, person)}
           blog post #{post_link(blog, post)}.)
      when "Person"
        %(#{person_link(activity.item.commenter)} commented on 
          #{wall(activity)}.)
      when "Event"
        event = activity.item.commentable
        commenter = activity.item.commenter
        %(#{person_link(commenter)} commented on 
          #{someones(event.person, commenter)} event: 
          #{event_link(event.title, event)}.)
      end
    when "Connection"
      %(#{person_link(activity.item.person)} and
        #{person_link(activity.item.contact)}
        have connected.)
    when "ForumPost"
      post = activity.item
      %(#{person_link(person)} made a post on the forum topic
        #{topic_link(post.topic)}.)
    when "Topic"
      %(#{person_link(person)} created the new discussion topic
        #{topic_link(activity.item)}.)
    when "Photo"
      %(#{person_link(person)}'s profile picture has changed.)
    when "Person"
      %(#{person_link(person)}'s description has changed.)
    else
      raise "Invalid activity type #{activity_type(activity).inspect}"
    end
  end
  
  def minifeed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      %(#{person_link(person)} made a
        #{post_link("new blog post", blog, post)}.)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person_link(person)} made a comment to
           #{someones(blog.person, person)}
           blog post #{post_link(blog, post)}.)
        %(#{person_link(person)} made a comment on
          #{someones(blog.person, person)} 
          #{post_link("blog post", post.blog, post)}.)
      when "Person"
        %(#{person_link(activity.item.commenter)} commented on 
          #{wall(activity)}.)
      when "Event"
        %(#{person_link(activity.item.commenter)} commented on 
          #{someones(activity.item.commentable.person, activity.item.commenter)} #{event_link("event", activity.item)}.)
      end
    when "Connection"
      %(#{person_link(person)} and #{person_link(activity.item.contact)}
        have connected.)
    when "ForumPost"
      topic = activity.item.topic
      %(#{person_link(person)} made a #{topic_link("forum post", topic)}.)
    when "Topic"
      %(#{person_link(person)} created a 
        #{topic_link("new discussion topic", activity.item)}.)
    when "Photo"
      %(#{person_link(person)}'s profile picture has changed.)
    when "Person"
      %(#{person_link(person)}'s description has changed.)
    else
      raise "Invalid activity type #{activity_type(activity).inspect}"
    end
  end
  
  # Given an activity, return the right icon.
  def feed_icon(activity)
    img = case activity_type(activity)
            when "BlogPost"
              "blog.gif"
            when "Comment"
              parent_type = activity.item.commentable.class.to_s
              case parent_type
              when "BlogPost"
                "comment.gif"
              when "Person"
                "signal.gif"
              end
            when "Connection"
              "switch.gif"
            when "ForumPost"
              "new.gif"
            when "Topic"
              "add.gif"
            when "Photo"
              "camera.gif"
            when "Person"
                "edit.gif"
            else
              raise "Invalid activity type #{activity_type(activity).inspect}"
            end
    image_tag("icons/#{img}", :class => "icon")
  end
  
  def someones(person, commenter, link = true)
    link ? "#{person_link(person)}'s" : "#{h person.name}'s"
  end
  
  def blog_link(text, blog)
    link_to(text, blog_path(blog))
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
    link_to(text, forum_topic_path(topic.forum, topic))
  end

  def event_link(text, event)
    link_to(text, event_path(event))
  end


  # Return a link to the wall.
  def wall(activity)
    commenter = activity.person
    person = activity.item.commentable
    link_to("#{someones(person, commenter, false)} wall",
            person_path(person, :anchor => "wall"))
  end
  
  private
  
    # Return the type of activity.
    # We switch on the class.to_s because the class itself is quite long
    # (due to ActiveRecord).
    def activity_type(activity)
      activity.item.class.to_s      
    end
end
