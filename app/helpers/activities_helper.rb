module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "BlogPost"
      post = activity.item
      blog = post.blog
      view_blog = blog_link("View #{h person.name}'s blog", blog)
      %(#{person_link(person)} #{t('shared.minifeed.made_a')} #{t('shared.minifeed.blog_post')}: 
      #{post_link(blog, post)}.<br /> #{view_blog}.)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person_link(person)} #{t('shared.minifeed.commented')} #{t('to')} #{someones(blog.person, person)}
         #{t('shared.minifeed.blog_post')} #{post_link(blog, post)}.)
      when "Person"
        %(#{person_link(activity.item.commenter)} #{t('shared.minifeed.commented')} #{t('on')} #{wall(activity)}.)
      when "Event"
        event = activity.item.commentable
        commenter = activity.item.commenter
        %(#{person_link(commenter)} #{t('shared.minifeed.commented')} #{t('on')} #{someones(event.person, commenter)} 
         #{t('event')}: #{event_link(event.title, event)}.)
      end
    when "Connection"
      %(#{person_link(activity.item.person)} #{t('and')} #{person_link(activity.item.contact)} 
      #{t('shared.minifeed.have_connected')}.)
    when "ForumPost"
      post = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.made_post_on_forum_topic')}: #{topic_link(post.topic)}.)
    when "Topic"
      %(#{person_link(person)} #{t('shared.minifeed.created_a')} #{t('shared.minifeed.new_discussion_topic')} 
      #{topic_link(activity.item)}.)
    when "Photo"
      %(#{person_link(person)}#{t('shared.minifeed.profile_picture_changed')}.)
    when "Person"
      %(#{person_link(person)}#{t('shared.minifeed.description_changed')}.)
    when "Group"
      %(#{person_link(person)} #{t('shared.minifeed.created_the_group')} '#{group_link(Group.find(activity.item))}')
    when "Membership"
      %(#{person_link(person)} #{t('shared.minifeed.joined_the_group')} '#{group_link(Group.find(activity.item.group))}')
    when "Event"
      event = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.event_created')}: #{event_link(event.title, event)}.)
    when "EventAttendee"
      event = activity.item.event
      %(#{person_link(person)} #{t('shared.minifeed.is_attending')} #{someones(event.person, person)} #{t('event')}: 
        #{event_link(event.title, event)}.)
    when "Req"
      req = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.req_created')}: #{req_link(req.name, req)}.)
    when "Offer"
      offer = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.offer_created')}: #{offer_link(offer.name, offer)}.)
    when "Exchange"
      exchange = activity.item
      if exchange.group.nil?
        %(#{person_link(person)} #{t('earned')} #{exchange.amount} #{t('shared.minifeed.hours_for')} 
        #{metadata_link(exchange.metadata)}.)
      else
        %(#{person_link(person)} #{t('earned')} #{exchange.amount} #{exchange.group.unit} #{t('for')} 
        #{metadata_link(exchange.metadata)} #{t('in')} #{group_link(exchange.group)}.)
      end
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
      %(#{person.name} #{t('shared.minifeed.made_a')} #{post_link(t('shared.minifeed.new_blog_post'), blog, post)}.)
    when "Comment"
      parent = activity.item.commentable
      parent_type = parent.class.to_s
      case parent_type
      when "BlogPost"
        post = activity.item.commentable
        blog = post.blog
        %(#{person.name} #{t('shared.minifeed.commented')} #{t('to')} #{someones(blog.person, person)} 
        #{t('shared.minifeed.blog_post')} #{post_link(blog, post)}.)
        %(#{person.name} #{t('shared.minifeed.commented')} #{t('on')} 
        #{someones(blog.person, person)} #{post_link(t('shared.minifeed.blog_post'), post.blog, post)}.)
      when "Person"
        %(#{activity.item.commenter.name} #{t('shared.minifeed.commented')} #{t('on')} #{wall(activity)}.)
      when "Event"
        event = activity.item.commentable
        %(#{activity.item.commenter.name} #{t('shared.minifeed.commented')} #{t('on')}
        #{someones(event.person, activity.item.commenter)} #{event_link(t('event'), event)}.)
      end
    when "Connection"
      %(#{person.name} #{t('and')} #{activity.item.contact.name} #{t('shared.minifeed.have_connected')}.)
    when "ForumPost"
      topic = activity.item.topic
      %(#{person.name} #{t('shared.minifeed.made_a')} #{topic_link(t('shared.minifeed.forum_post'), topic)}.)
    when "Topic"
      %(#{person.name} #{t('shared.minifeed.created_a')} #{topic_link(t('shared.minifeed.new_discussion_topic'), activity.item)}.)
    when "Photo"
      %(#{person.name}#{t('shared.minifeed.profile_picture_changed')}.)
    when "Person"
      %(#{person.name}#{t('shared.minifeed.description_changed')}.)
    when "Group"
      %(#{person.name} #{t('shared.minifeed.created_the_group')} '#{group_link(Group.find(activity.item))}')
    when "Membership"
      %(#{person.name} #{t('shared.minifeed.joined_the_group')} '#{group_link(Group.find(activity.item.group))}')
    when "Event"
      %(#{person.name}s #{t('shared.minifeed.has_created_a_new')} #{event_link(t('event'), activity.item)}.)
    when "EventAttendee"
      event = activity.item.event
      %(#{person.name} #{t('shared.minifeed.is_attending')} #{someones(event.person, person)} 
      #{event_link(t('event'), event)}.)
    when "Req"
      req = activity.item
      %(#{person.name} #{t('shared.minifeed.req_created')}: #{req_link(req.name, req)}.)
    when "Offer"
      offer = activity.item
      %(#{person.name} #{t('shared.minifeed.offer_created')}: #{offer_link(offer.name, offer)}.)
    when "Exchange"
      exchange = activity.item
      if exchange.group.nil?
        %(#{person.name} #{t('earned')} #{exchange.amount} #{t('shared.minifeed.hour_for')} #{metadata_link(exchange.metadata)}.)
      else
        %(#{person.name} #{t('earned')} #{exchange.amount} #{exchange.group.unit} #{t('for')} 
        #{metadata_link(exchange.metadata)} #{t('in')} #{group_link(exchange.group)}.)
      end
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
              when "Event"
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
            when "Group"
              "new.gif"
            when "Membership"
              "add.gif"
            when "Event"
              "time.gif"
            when "EventAttendee"
              "check.gif"
            when "Req"
              "new.gif"
            when "Offer"
              "new.gif"
            when "Exchange"
              "favorite.gif"
            else
              raise "Invalid activity type #{activity_type(activity).inspect}"
            end
    image_tag("icons/#{img}", :class => "icon")
  end
  
  def someones(person, commenter, link = true)
    link ? "#{person_link(person)}'s" : "#{h person.name}'s"
  end
  
  def blog_link(text, blog)
    link_to(h(text), blog_path(blog))
  end
  
  def post_link(text, blog, post = nil)
    if post.nil?
      post = blog
      blog = text
      text = post.title
    end
    link_to(h(text), blog_post_path(blog, post))
  end
  
  def topic_link(text, topic = nil)
    if topic.nil?
      topic = text              # Eh?  This makes no sense...
      text = topic.name
    end
    link_to(h(text), forum_topic_path(topic.forum, topic), :class => "show-follow")
  end

  def event_link(text, event)
    link_to(h(text), event_path(event))
  end

  def metadata_link(metadata)
    if metadata.nil?
      "unknown!" # this should never happen.
    elsif metadata.class == Req
      link_to(h(metadata.name), req_path(metadata), :class => "show-follow")
    else
      link_to(h(metadata.name), offer_path(metadata), :class => "show-follow")
    end
  end

  def req_link(text, req)
    link_to(h(text), req_path(req), :class => "show-follow")
  end

  def offer_link(text, offer)
    link_to(h(text), offer_path(offer), :class => "show-follow")
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
