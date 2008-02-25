# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu
    if logged_in?
      [{ :content => "Home",   :href => home_path },
       { :content => "My Profile" , :href => person_path(current_person) },
       { :content => "My Photos" , :href => photos_path },
       { :content => "People", :href => people_path },
       { :content => "Messages", :href => messages_path },
       { :content => "Forum", :href => forum_path(1) }]
    else
      [{ :content => "Home",   :href => home_path },
       { :content => "People", :href => people_path }]
    end
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
  
  def set_main_title(title = "Instant Social")
    content_for :main_title do 
      title
    end
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
