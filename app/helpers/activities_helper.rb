module ActivitiesHelper

  # Given an activity, return a message for the feed for the activity's class.
  def feed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "Connection"
      %(#{person_link(activity.item.person)} #{t('and')} #{person_link(activity.item.contact)} 
      #{t('shared.minifeed.have_connected')}.).html_safe
    when "ForumPost"
      post = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.made_post_on_forum_topic')}: #{topic_link(post.topic)}.).html_safe
    when "Topic"
      %(#{person_link(person)} #{t('shared.minifeed.created_a')} #{t('shared.minifeed.new_discussion_topic')} 
      #{topic_link(activity.item)}.).html_safe
    when "Photo"
      %(#{person_link(person)}#{t('shared.minifeed.profile_picture_changed')}.).html_safe
    when "Person"
      %(#{person_link(person)}#{t('shared.minifeed.description_changed')}.).html_safe
    when "Group"
      %(#{person_link(person)} #{t('shared.minifeed.created_the_group')} '#{group_link(Group.find(activity.item))}').html_safe
    when "Membership"
      %(#{person_link(person)} #{t('shared.minifeed.joined_the_group')} '#{group_link(Group.find(activity.item.group))}').html_safe
    when "Req"
      req = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.req_created')}: #{req_link(req.name, req)}.).html_safe
    when "Offer"
      offer = activity.item
      %(#{person_link(person)} #{t('shared.minifeed.offer_created')}: #{offer_link(offer.name, offer)}.).html_safe
    when "Exchange"
      exchange = activity.item
      %(#{person_link(person)} #{t('earned')} #{exchange.amount} #{exchange.group.unit} #{t('for')} 
      #{metadata_link(exchange.metadata)} #{t('in')} #{group_link(exchange.group)}.).html_safe
    else
      raise "Invalid activity type #{activity_type(activity).inspect}"
    end
  end
  
  def minifeed_message(activity)
    person = activity.person
    case activity_type(activity)
    when "Connection"
      raw %(#{h person.display_name} #{t('and')} #{h activity.item.contact.name} #{t('shared.minifeed.have_connected')}.).html_safe
    when "ForumPost"
      topic = activity.item.topic
      %(#{h person.display_name} #{t('shared.minifeed.made_a')} #{topic_link(t('shared.minifeed.forum_post'), topic)}.).html_safe
    when "Topic"
      %(#{h person.display_name} #{t('shared.minifeed.created_a')} #{topic_link(t('shared.minifeed.new_discussion_topic'), activity.item)}.).html_safe
    when "Photo"
      %(#{h person.display_name}#{t('shared.minifeed.profile_picture_changed')}.).html_safe
    when "Person"
      %(#{h person.display_name}#{t('shared.minifeed.description_changed')}.).html_safe
    when "Group"
      %(#{h person.display_name} #{t('shared.minifeed.created_the_group')} '#{group_link(Group.find(activity.item))}').html_safe
    when "Membership"
      %(#{h person.display_name} #{t('shared.minifeed.joined_the_group')} '#{group_link(Group.find(activity.item.group))}').html_safe
    when "Req"
      req = activity.item
      %(#{h person.display_name} #{t('shared.minifeed.req_created')}: #{req_link(req.name, req)}.).html_safe
    when "Offer"
      offer = activity.item
      %(#{h person.display_name} #{t('shared.minifeed.offer_created')}: #{offer_link(offer.name, offer)}.).html_safe
    when "Exchange"
      exchange = activity.item
      %(#{h person.display_name} #{t('earned')} #{exchange.amount} #{exchange.group.unit} #{t('for')} 
      #{metadata_link(exchange.metadata)} #{t('in')} #{group_link(exchange.group)}.).html_safe
    else
      raise "Invalid activity type #{activity_type(activity).inspect}"
    end
  end
  
  # Given an activity, return the right icon.
  def feed_icon(activity)
    img = case activity_type(activity)
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
    link ? "#{person_link(person)}'s" : "#{h person.display_name}'s"
  end
  
  def topic_link(text, topic = nil)
    if topic.nil?
      topic = text              # Eh?  This makes no sense...
      text = topic.name
    end
    link_to(h(text), forum_topic_path(topic.forum, topic), :class => "show-follow")
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

  private
  
    # Return the type of activity.
    # We switch on the class.to_s because the class itself is quite long
    # (due to ActiveRecord).
    def activity_type(activity)
      activity.item.class.to_s      
    end
end
