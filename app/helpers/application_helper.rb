# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_page_pre22?(options)
    url_string = CGI.escapeHTML(url_for(options))
    request_uri = request.fullpath
    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    else
      url_string == request_uri
    end
  end

  def list_link_with_active(name, options = {}, html_options = {}, &block)
    opts = {}
    opts.merge!(:class => "active") if current_page_pre22?(options)
    content_tag(:li, link_to(name, options, html_options, &block), opts)
  end
  
  ## Menu helpers
  
  def menu
    home     = menu_element("Home",   home_path)
    categories = menu_element("SkillBank", categories_path)
    people   = menu_element("People", people_path)
    if Forum.count == 1
      forum = menu_element("Forum", forum_path(Forum.find(:first)))
    else
      forum = menu_element("Forums", forums_path)
    end
    if logged_in?
      profile  = menu_element("Profile",  person_path(current_person))
      offers = menu_element("Offers", offers_path)
      requests = menu_element("Requests", reqs_path)
      messages = menu_element("Inbox", messages_path)
#      blog     = menu_element("Blog",     blog_path(current_person.blog))
      photos   = menu_element("Photos",   photos_path)
        groups = menu_element("Groups", groups_path())
#      contacts = menu_element("Contacts",
#                              person_connections_path(current_person))
#      links = [home, profile, contacts, messages, blog, people, forum]
      #events   = menu_element("Events", events_path)
        links = [home, profile, categories, offers, requests, people, messages, groups, forum]
      # TODO: remove 'unless Rails.env.production?' once events are ready.
      #links.push(events) #unless Rails.env.production?
    else
      #links = [home, people]
      links = [home, categories]
      if !global_prefs.about.blank?
        links.push(menu_element("About", about_url))
      end
      if !global_prefs.practice.blank?
        links.push(menu_element("Practice", practice_url))
      end
      if !global_prefs.steps.blank?
        links.push(menu_element("Steps", steps_url))
      end
      if !global_prefs.questions.blank?
        links.push(menu_element("Q/A", questions_url))
      end
      if !global_prefs.contact.blank?
        links.push(menu_element("Contact", contact_url))
      end
    end

    links
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end

  def waiting_image
    img = image_tag("loading.gif",:class=>"wait",:alt=>"wait")
    "<span class='wait' style='display:none'>#{img}</span>".html_safe
  end

  def organization_image(person)
    if person.org?
      image_tag("icons/community_small.png",:title=> t('people.show.organization_profile'))
    else
      ""
    end
  end

  def currency_units
    "<span id='units' class='small'>#{t('currency_unit_plural')}</span>".html_safe
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
  
  def admin?
    logged_in? and current_person.admin?
  end
  
  # Set the input focus for a specific id
  # Usage: <%= set_focus_to 'form_field_label' %>
  def set_focus_to(id)
    javascript_tag("jQuery('##{id}').focus()");
  end

  def markdown(text)
    options = [:hard_wrap, :no_intraemphasis]
    Redcarpet.new(text || "", *options).to_html.html_safe
  end

  # Display text by sanitizing and formatting.
  # The html_options, if present, allow the syntax
  #  display("foo", :class => "bar")
  #  => '<p class="bar">foo</p>'
  def display(text, html_options = nil)
    begin
      if html_options
        html_options = html_options.stringify_keys
        tag_opts = tag_options(html_options)
      else
        tag_opts = nil
      end
      processed_text = format(sanitize(text))
    rescue
      # Sometimes Markdown throws exceptions, so rescue gracefully.
      processed_text = content_tag(:p, sanitize(text))
    end
    add_tag_options(processed_text, tag_opts).html_safe
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
    #concat(content)
  end

  def account_link(account, options = {})
    path = person_account_path(account.person,account) # XXX link to transactions
    img = image_tag("icons/bargraph.gif")
    unless account.group
      str = ""
    else
      credit_limit = account.credit_limit.nil? ? "" : "(limit: #{account.credit_limit.to_s})"
      action = "#{account.balance} #{account.group.unit} #{credit_limit}"
      str = link_to(img,path, options)
      str << " "
      str << link_to_unless_current(action, path, options)
      # str.html_safe
    end
  end

  def exchange_link(person, group = nil, options = {})
    img = image_tag("icons/switch.gif")
    path = new_person_exchange_path(person, ({:group => group.id} unless group.nil?))
    action = "Give credit"
    str = link_to(img,path,options)
    str << " "
    str << link_to_unless_current(action, path, options)
    # str.html_safe
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
    str << " "
    str << link_to_unless_current(action, path, opts)
  end

  def first_n_words(s, n=20)
    s[/(\s*\S+){,#{n}}/]
  end

  # Return a formatting note (depends on the presence of a Markdown library)
  def formatting_note
    if markdown?
      %(HTML and
        #{link_to("Markdown",
                  "http://daringfireball.net/projects/markdown/basics",
                  :popup => true)}
       formatting supported)
    else 
      "HTML formatting supported"
    end
  end

def relative_time_ago_in_words(time)
  if time > Time.now
    t('in') + " " + time_ago_in_words(time)
  else
    time_ago_in_words(time) + " " + t('ago')
  end
end

  private
  
    def inflect(word, number)
      number > 1 ? word.pluralize : word
    end
    
    def add_tag_options(text, options)
      text.gsub("<p>", "<p#{options}>")
    end
    
    # Format text using BlueCloth (or RDiscount) if available.
    def format(text)
      if text.nil?
        ""
      elsif defined?(RDiscount)
        RDiscount.new(text).to_html
      elsif defined?(BlueCloth)
        BlueCloth.new(text).to_html
      elsif no_paragraph_tag?(text)
        content_tag :p, text
      else
        text
      end
    end
    
    # Is a Markdown library present?
    def markdown?
      defined?(RDiscount) or defined?(BlueCloth)
    end
    
    # Return true if the text *doesn't* start with a paragraph tag.
    def no_paragraph_tag?(text)
      text !~ /^\<p/
    end
end
