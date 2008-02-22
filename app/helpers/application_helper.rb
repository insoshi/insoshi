# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu
    if logged_in?
      [{ :content => "Home",   :href => home_path },
       { :content => "My Profile" , :href => person_path(current_person) },
       { :content => "My Photos" , :href => photos_path },
       { :content => "People", :href => people_path }]
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
end
