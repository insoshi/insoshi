# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  ## Menu helpers
  
  def menu
    home     = menu_element("Home",   home_path)
    people   = menu_element("People", people_path)
    forum    = menu_element("Forum",  forum_path)
    if logged_in?
      profile  = menu_element("Profile",  person_path(current_person))
      messages = menu_element("Messages", messages_path)
      blog     = menu_element("Blog",     blog_posts_path(current_person.blog))
      photos   = menu_element("Photos",   photos_path)
      contacts = menu_element("Contacts", connections_path)
      [home, profile, contacts, messages, blog, people, forum]
    else
      [home, people, forum]
    end
  end
  
  def menu_element(content, address)
    { :content => content, :href => address }
  end
  
  def menu_link_to(link, options = {})
    options.merge!({ :id => "current" }) if current_page?(link[:href])
    link_to(link[:content], link[:href], options)
  end
  
  # Set the input focus for a specific id
  # Usage: <%= set_focus_to_id 'form_field_label' %>
  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
  
  # Output a column div.
  # The current two-column layout has primary & secondary columns.
  # The options hash is handled so that the caller can pass options to 
  # content_tag.
  def column_div(options = {}, &block)
    t = options.delete(:type)
    if t.nil?
      width = options.delete(:width)
      order = options.delete(:order)
      klass = "column #{order} span-#{width}"
    else
      case t
      when :primary
        width = LEFT
        order = "first"
      when :secondary
        width = RIGHT
        order = "last"
      when :full
        width = FULL
        order = "first last"
      else
        raise ArgumentError
      end
      klass = "column #{order} span-#{width}"
    end
    # Allow callers to pass in additional classes.
    options[:class] = "#{klass} #{options[:class]}".strip
    content = content_tag(:div, capture(&block), options)
    concat(content, block.binding)
  end

  # TODO: polish these & move them somewhere
  def linked_image(person, options = {})
    href = options[:href] || person
    o = { :size => 'thumbnail' }.merge(options)    
    link_to image_tag(person.send(o[:size])), href 
  end

  def name_link(person, options = {})
     link_to h(person.name), person, options
  end

  def email_link(person, options = {})
    reply = options[:replying_to]
    if reply
      path = reply_message_path(reply)
    else
      path = new_person_message_path(person)
    end
    img = image_tag "email.png", :class => "inlined"
    action = reply.nil? ? "Send message" : "Send reply"
    opts = { :class => 'email-link' }
    str = link_to(img, path, opts)
    str << "&nbsp;"
    str << link_to_unless_current(action, path, opts)
  end
end
