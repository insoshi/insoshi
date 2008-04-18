module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity)
    # Switch on the class.to_s.  (The class itself is long & complicated.)
    person = activity.person
    case activity.item_type
    when "BlogPost"
      post = activity.item
      blog = post.blog
      view_blog = blog_link("View #{person.name}'s blog", blog)
      %(#{person_link(person)} made a blog post titled
        #{post_link(blog, post)}.<br /> #{view_blog})
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person_link(person)} made a comment to
           #{someones(blog.person)} blog post #{post_link(blog, post)}.)
      when "Person"
        %(#{person_link(activity.item.commenter)} commented on #{wall(person)})
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
    else
      raise "Invalid activity type #{activity.item_type.inspect}"
    end
  end
  
  def minifeed_message(activity)
    person = activity.person
    case activity.item_type
    when "BlogPost"
      post = activity.item
      blog = post.blog
      %(#{person_link(person)} made a
        #{post_link("new blog post", blog, post)})
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person_link(person)} made a comment on #{someones(post.blog.person)} 
          #{post_link("blog post", post.blog, post)})
      when "Person"
        %(#{person_link(activity.item.commenter)} commented on #{wall(person)})
      end
    when "Connection"
      %(#{person_link(person)} and #{person_link(activity.item.contact)}
        have connected.)
    when "ForumPost"
      topic = activity.item.topic
      # TODO: deep link this to the post
      %(#{person_link(person)} made a #{topic_link("forum post", topic)}.)
    when "Person"
      %(#{person_link(person)} joined the network!)
    when "Topic"
      %(#{person_link(person)} created a 
        #{topic_link("new discussion topic", activity.item)}.)
    else
      raise "Invalid activity type #{activity.item_type.inspect}"
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
    # We normally write link_to(..., person) for brevity, but that breaks
    # activities_helper_spec due to an RSpec bug.
    link_to(text, person_path(person))
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

  # Return a link to the wall.
  def wall(person)
    link_to("#{someones(person, false)} wall",
            person_path(person, :anchor => "wall"))
  end
end
