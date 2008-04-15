# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  ## Menu helpers
  
  def menu
    home     = menu_element("Home",   home_path)
    people   = menu_element("People", people_path)
    forum    = menu_element(inflect("Forum", Forum.count),  forums_path)
    if logged_in? and not admin_view?
      profile  = menu_element("Profile",  person_path(current_person))
      messages = menu_element("Messages", messages_path)
      blog     = menu_element("Blog",     blog_path(current_person.blog))
      photos   = menu_element("Photos",   photos_path)
      contacts = menu_element("Contacts",
                              person_connections_path(current_person))
      [home, profile, contacts, messages, blog, people, forum]
    elsif logged_in? and admin_view?
      home =    menu_element("Home", admin_home_path)
      people =  menu_element("People", admin_people_path)
      forums =  menu_element(inflect("Forum", Forum.count),
                             admin_forums_path)
      preferences = menu_element("Preferences", admin_preferences_path)
      [home, people, forums, preferences]
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
  
  # Return true if the user is viewing the site in admin view.
  def admin_view?
    params[:controller] =~ /admin/ and logged_in? and current_person.admin?
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
  # The LEFT, RIGHT, and FULL constants are defined in 
  # config/initializers/global_constants.rb
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

private
  
  def inflect(word, number)
    number > 1 ? word.pluralize : word
  end

end
