# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu
    [{ :content => "Home", :href => home_url },
     { :content => "People", :href => people_url }]
  end
  
  def menu_link_to(link, options = {})
    options.merge!({ :id => "current" }) if current_page?(link[:href])
    link_to(link[:content], link[:href], options)
  end
end
