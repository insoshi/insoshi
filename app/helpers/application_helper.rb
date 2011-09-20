# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_page_pre22?(options)
    url_string = CGI.escapeHTML(url_for(options))
    request = @controller.request
    request_uri = request.request_uri
    if url_string =~ /^\w+:\/\//
      url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
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
    if logged_in? and not admin_view?
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
      # TODO: remove 'unless production?' once events are ready.
      #links.push(events) #unless production?
      
    elsif logged_in? and admin_view?
      spam = menu_element("eNews", admin_broadcast_emails_path)
      people =  menu_element("People", admin_people_path)
      exchanges =  menu_element("Ledger", admin_exchanges_path)
      feed = menu_element("Feed", admin_feed_posts_path)
      preferences = menu_element("Prefs", admin_preferences_path)
      categories = menu_element("Categories", "/categories")
      links = [spam, categories, people, exchanges, feed, preferences]
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
    "<span class='wait' style='display:none'><img alt='wait' class='wait' src='/images/loading.gif'></span>"
  end

  def organization_image(person)
    if person.org?
      "<img title=\"#{t('people.show.organization_profile')}\" src=\"/images/icons/community_small.png\" />"
    else
      ""
    end
  end

  def currency_units
    "<span id='units' class='small'>#{t('currency_unit_plural')}</span>"
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
  # Usage: <%= set_focus_to 'form_field_label' %>
  def set_focus_to(id)
    javascript_tag("jQuery('##{id}').focus()");
  end
 
  # Same as Rails' simple_format helper without using paragraphs
  def simple_format_without_paragraph(text)
    text.to_s.
      gsub(/\r\n?/, "\n").                    # \r\n and \r -> \n
      gsub(/\n\n+/, "<br /><br />").          # 2+ newline  -> 2 br
      gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   -> br
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
    add_tag_options(processed_text, tag_opts)
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
    concat(content)
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
    end
  end

  def exchange_link(person, group = nil, options = {})
    img = image_tag("icons/switch.gif")
    path = new_person_exchange_path(person, ({:group => group.id} unless group.nil?))
    action = "Give credit"
    str = link_to(img,path,options)
    str << " "
    str << link_to_unless_current(action, path, options)
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
    time_ago_in_words(time) + " ago"  # rob young - this needs to be added to the language file!
  end
end

# YUI
def yui_headers(textspace)  
    @yui_head = capture do
         content_for(:head) {'           
        <!-- Combo-handled YUI CSS files: -->
        <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.6.0/build/assets/skins/sam/skin.css">
        <!-- Combo-handled YUI JS files: -->
        <script type="text/javascript" src="http://yui.yahooapis.com/combo?2.6.0/build/yahoo-dom-event/yahoo-dom-event.js&2.6.0/build/container/container_core-min.js&2.6.0/build/menu/menu-min.js&2.6.0/build/element/element-beta-min.js&2.6.0/build/button/button-min.js&2.6.0/build/editor/editor-min.js"></script>
'}
  end
  yui_rte(textspace)  
end

def yui_headers_debug(textspace) 
    @yui_head = capture do
         content_for(:head) {'           
           <!-- Combo-handled YUI CSS files: -->
           <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.6.0/build/menu/assets/skins/sam/menu.css&2.6.0/build/button/assets/skins/sam/button.css&2.6.0/build/editor/assets/skins/sam/editor.css&2.6.0/build/logger/assets/skins/sam/logger.css">
           <!-- Combo-handled YUI JS files: -->
           <script type="text/javascript" src="http://yui.yahooapis.com/combo?2.6.0/build/yahoo/yahoo-debug.js&2.6.0/build/dom/dom-debug.js&2.6.0/build/event/event-debug.js&2.6.0/build/container/container_core-debug.js&2.6.0/build/menu/menu-debug.js&2.6.0/build/element/element-beta-debug.js&2.6.0/build/button/button-debug.js&2.6.0/build/editor/editor-debug.js&2.6.0/build/logger/logger-debug.js"></script>
'}
  end
  yui_rte(textspace)  
end

def yui_headers_raw(textspace) 
    @yui_head = capture do
         content_for(:head) {'           
           <!-- Combo-handled YUI CSS files: -->
           <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/combo?2.6.0/build/menu/assets/skins/sam/menu.css&2.6.0/build/button/assets/skins/sam/button.css&2.6.0/build/editor/assets/skins/sam/editor.css">
           <!-- Combo-handled YUI JS files: -->
           <script type="text/javascript" src="http://yui.yahooapis.com/combo?2.6.0/build/yahoo/yahoo.js&2.6.0/build/dom/dom.js&2.6.0/build/event/event.js&2.6.0/build/container/container_core.js&2.6.0/build/menu/menu.js&2.6.0/build/element/element-beta.js&2.6.0/build/button/button.js&2.6.0/build/editor/editor.js"></script>
'}
  end
  yui_rte(textspace)  
end

def yui_rte(textspace) 
      @yui_text = capture do
         content_for(:yui_rte) {'           
           <script type="text/javascript">
           var myEditor = new YAHOO.widget.Editor("' + textspace + '", {
               handleSubmit: true,
               dompath: false, //Turns on the bar at the bottom
               animate: true, //Animates the opening, closing and moving of Editor windows
               collapse: true,
               titlebar: "This is text",
               draggable: false,
               buttons: [
                         { group: "fontstyle", label: "Font Name and Size",
                             buttons: [
                                 { type: "select", label: "Arial", value: "fontname", disabled: true,
                                     menu: [
                                         { text: "Arial", checked: true },
                                         { text: "Arial Black" },
                                         { text: "Comic Sans MS" },
                                         { text: "Courier New" },
                                         { text: "Lucida Console" },
                                         { text: "Tahoma" },
                                         { text: "Times New Roman" },
                                         { text: "Trebuchet MS" },
                                         { text: "Verdana" }
                             ]
                           },
                           { type: "spin", label: "13", value: "fontsize", range: [ 9, 75 ], disabled: true }
                       ]
                   },
                   { type: "separator" },
                   { group: "textstyle", label: "Font Style",
                       buttons: [
                           { type: "push", label: "Bold CTRL + SHIFT + B", value: "bold" },
                           { type: "push", label: "Italic CTRL + SHIFT + I", value: "italic" },
                           { type: "push", label: "Underline CTRL + SHIFT + U", value: "underline" },
                           { type: "separator" },
                           { type: "color", label: "Font Color", value: "forecolor", disabled: true },
                           { type: "color", label: "Background Color", value: "backcolor", disabled: true }
                       ]
                   },
                   { type: "separator" },
                   { group: "indentlist", label: "Lists",
                       buttons: [
                           { type: "push", label: "Create an Unordered List", value: "insertunorderedlist" },
                           { type: "push", label: "Create an Ordered List", value: "insertorderedlist" }
                       ]
                   },
                   { type: "separator" },
                   { group: "insertitem", label: "Insert Item",
                       buttons: [
                           { type: "push", label: "HTML Link CTRL + SHIFT + L", value: "createlink", disabled: true },
                           { type: "push", label: "Insert Image", value: "insertimage" }
                       ]
                   }
               ]
               
           });
           myEditor.render();
           </script>
'}
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
