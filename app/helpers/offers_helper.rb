module OffersHelper
  def active_offers_class
    if params[:scope]
      "toggle-active-offers"
    else
      "toggle-active-offers filter_selected"
    end
  end

  def all_offers_class
    if params[:scope]
      "toggle-all-offers filter_selected"
    else
      "toggle-all-offers"
    end
  end

  def formatted_offer_categories(categories)
    text = ""
    categories.each {|c| text << c + "<br>"}
    text.html_safe
  end

  # Return an offer's image link.
  # The default is to display the offer's icon linked to a larger photo.
  def offer_image_link(offer, options = {})
    link = options[:link] || offer
    image = options[:image] || :icon
    image_options = { :title => h(offer.name), :alt => h(offer.name) }
    unless options[:image_options].nil?
      image_options.merge!(options[:image_options])
    end
    link_options =  { :title => h(offer.name) }
    unless options[:link_options].nil?
      link_options.merge!(options[:link_options])
    end
    content = image_tag(offer.send(image), image_options)
    # This is a hack needed for the way the designer handled rastered images
    # (with a 'vcard' class).
    if options[:vcard]
      content = %(#{content}#{content_tag(:span, h(offer.name),
                                                 :class => "fn" )})
    end
    link_to(content, link, link_options)
  end
end
