module MessagesHelper
  
  def list_link_with_active(name, options = {}, html_options = {}, &block)
    opts = {}
    opts.merge!(:class => "active") if current_page?(options)
    content_tag(:li, link_to(name, options, html_options, &block), opts)
  end

  def message_icon(message)
    if message.new?(current_person)
      image_tag("icons/email_add.png", :class => "icon")
    elsif message.replied_to?
      image_tag("icons/email_go.png", :class => "icon")
    end
  end
end