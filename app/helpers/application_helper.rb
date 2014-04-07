# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  
  def stripe_include_tag
    content_for(:head) do
      javascript_include_tag "https://js.stripe.com/v2/"
    end
  end

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

  def theme_options
    theme_matrix.keys.map {|theme_name| "<option>#{theme_name}</option>"}.join
  end

  def theme_matrix
    {"default" => "http://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.2/css/bootstrap.no-icons.min.css",
      "amelia" => "http://bootswatch.com/amelia/bootstrap.min.css",
      "cerulean" => "http://bootswatch.com/cerulean/bootstrap.min.css",
      "cosmo" => "http://bootswatch.com/cosmo/bootstrap.min.css",
      "cyborg" => "http://bootswatch.com/cyborg/bootstrap.min.css",
      "flatly" => "http://bootswatch.com/flatly/bootstrap.min.css",
      "journal" => "http://bootswatch.com/journal/bootstrap.min.css",
      "readable" => "http://bootswatch.com/readable/bootstrap.min.css",
      "simplex" => "http://bootswatch.com/simplex/bootstrap.min.css",
      "slate" => "http://bootswatch.com/slate/bootstrap.min.css",
      "spacelab" => "http://bootswatch.com/spacelab/bootstrap.min.css",
      "superhero" => "http://bootswatch.com/superhero/bootstrap.min.css",
      "united" => "http://bootswatch.com/united/bootstrap.min.css"}
  end

  def theme_url(theme_name)
      theme_matrix[theme_name] || "http://netdna.bootstrapcdn.com/twitter-bootstrap/2.2.2/css/bootstrap.no-icons.min.css"
  end
  
  ## Menu helpers

  def display_help?
    !(
      global_prefs.about.blank? &&
      global_prefs.practice.blank? &&
      global_prefs.steps.blank? &&
      global_prefs.contact.blank? &&
      global_prefs.agreement.blank? &&
      global_prefs.questions.blank?
    )
  end
  
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
    markdown_parser.render(text).html_safe
  end

  def markdown_parser
    @markdown_parser ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(:hard_wrap => true, :filter_html => true, :safe_links_only => true))
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
    label = options[:label] || ""
    metric = case label
      when t('balance') then   nice_decimal(account.balance_with_initial_offset)  
      when t('paid') then   nice_decimal(account.paid) 
      when t('earned') then  nice_decimal(account.earned) 
      else 0
    end

    path = person_account_path(account.person,account) # XXX link to transactions
    img = image_tag("icons/bargraph.gif")
    unless account.group
      str = ""
    else
      credit_limit = account.credit_limit.nil? ? "" : "(limit: #{nice_decimal(account.credit_limit)})"
      action = "#{metric} #{account.group.unit} #{credit_limit}"
      str = link_to(img,path, options)
      str << " #{label}: "
      str << link_to_unless_current(action, path, options)
      # str.html_safe
    end
  end

  def exchange_link(counterparty, group = nil, options = {})
    if 'debit' == options[:transact]
      path = new_person_exchange_path(current_person, ({:group => group.id, :customer => counterparty.id}))
      action = t('exchanges.debit')
      img = image_tag("icons/remove.gif")
    else
      path = new_person_exchange_path(counterparty, ({:group => group.id} unless group.nil?))
      action = t('exchanges.credit')
      img = image_tag("icons/add.gif")
    end
    str = link_to(img,path,options)
    str << " "
    str << link_to_unless_current(action, path, options)
    # str.html_safe
  end

  def support_link(person, group = nil, options = {})
    img = image_tag("icons/question.gif")
    path = person_path(person)
    action = t('people.show.support_contact')
    str = link_to(img,path,options)
    str << " "
    str << link_to_unless_current(action, path, options)
    # str.html_safe
  end

  def email_link(person, options = {})
    reply = options[:replying_to]
    classes = ['email-link']
    classes << options[:class] if options[:class]

    if reply
      path = reply_message_path(reply)
    else
      path = new_person_message_path(person)
    end
    img = image_tag("icons/email.gif")
    action = reply.nil? ? t('exchanges.send_a_message') : "Send reply"
    opts = { :class => classes.join(' ') }
    str = link_to(img, path, opts)
    str << " "
    str << link_to_unless_current(action, path, opts)
  end

  def first_n_words(s, n=20)
    s.to_s[/(\s*\S+){,#{n}}/]
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
      t( 'ago_time', :date => time_ago_in_words(time) )
    end
  end

  def current_datetime_format
    if current_person && current_person.date_style
      TimeZone::Date_Style[current_person.date_style]
    else
      TimeZone::Date_Style[TimeZone.first.date_style]
    end
  end

def nice_decimal(decimal)
  number_with_precision(decimal, precision: 2)
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
