# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  ## Menu helpers
  
  def menu
    home     = menu_element("Home",   home_path)
    people   = menu_element("People", people_path)
    if Forum.count == 1
      forum = menu_element("Forum", forum_path(Forum.find(:first)))
    else
      forum = menu_element("Forums", forums_path)
    end
    resources = menu_element("Resources", "http://docs.insoshi.com/")
    if logged_in? and not admin_view?
      profile  = menu_element("Profile",  person_path(current_person))
      messages = menu_element("Messages", messages_path)
      blog     = menu_element("Blog",     blog_path(current_person.blog))
      photos   = menu_element("Photos",   photos_path)
      contacts = menu_element("Contacts",
                              person_connections_path(current_person))
      [home, profile, contacts, messages, blog, people, forum, resources]
    elsif logged_in? and admin_view?
      home =    menu_element("Home", home_path)
      people =  menu_element("People", admin_people_path)
      forums =  menu_element(inflect("Forum", Forum.count),
                             admin_forums_path)
      preferences = menu_element("Prefs", admin_preferences_path)
      [home, people, forums, preferences]
    else
      [home, people, forum, resources]
    end
  end
  
  def menu_element(content, address)
    { :content => content, :href => address }
  end
  
  def menu_link_to(link, options = {})
    link_to(link[:content], link[:href], options)
  end
  
  def menu_li(link, options = {})
    klass = "n-#{link[:content].downcase}"
    klass += " active" if current_page?(link[:href])
    content_tag(:li, menu_link_to(link, options), :class => klass)
  end
  
  # Return true if the user is viewing the site in admin view.
  def admin_view?
    params[:controller] =~ /admin/ and admin?
  end
  
  def admin?
    logged_in? and current_person.admin?
  end
  
  # Set the input focus for a specific id
  # Usage: <%= set_focus_to_id 'form_field_label' %>
  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
  
  # Display text by sanitizing and formatting.
  # The formatting is done by Markdown via the BlueCloth gem.
  # The html_options, if present, allow the syntax
  #  display("foo", :class => "bar")
  #  => '<p class="bar">foo</p>'
  def display(text, html_options = nil)
    if html_options
      html_options = html_options.stringify_keys
      tag_options = tag_options(html_options)
    else
      tag_options = nil
    end
    markdown(sanitize(text)).gsub("<p>", "<p#{tag_options}>")
  rescue
    # Sometimes Markdown throws exceptions, so rescue gracefully.
    content_tag(:p, sanitize(text))
  end
  
  # Output a column div.
  # The current two-column layout has primary & secondary columns.
  # The options hash is handled so that the caller can pass options to 
  # content_tag.
  # The LEFT, RIGHT, and FULL constants are defined in 
  # config/initializers/global_constants.rb
  def column_div(options = {}, &block)
    klass = options.delete(:type) == :primary ? "col1" : "col2"
    # Allow callers to pass in additional classes.
    options[:class] = "#{klass} #{options[:class]}".strip
    content = content_tag(:div, capture(&block), options)
    concat(content, block.binding)
  end

  def email_link(person, options = {})
    reply = options[:replying_to]
    if reply
      path = reply_message_path(reply)
    else
      path = new_person_message_path(person)
    end
    img = image_tag("icons/email.gif")
    action = reply.nil? ? "Send a message" : "Send reply"
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
