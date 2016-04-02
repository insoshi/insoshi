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

  #
  # function `horizontal_formatted_offer_categories` outputs an html string
  # that includes a prefix ( ie: Listed in: ) enclosed in <span> tags and the
  # following to be a comma seperated list of names.
  #
  def horizontal_formatted_offer_categories( categories, prefix_text = t('offers.partial.listed_in'))
    html = "<div class='horizontal-categories'><span>#{prefix_text}</span>&nbsp;"

    # Adding categories with commas - note extra comma to end
    categories.each { | c | html << h(c) + ', ' }

    # remove the accessive ', ' from the last position
    html = html[0..-3] << '</div>'
  end

  # Return an offer(or request)'s image link.
  # The default is to display the offer's icon linked to a larger photo.
  # this method is also used for request(req)
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

  # Offer Value provides a verbal description about the offers value. This is useful to show how much
  # the value is in the list view (index). If the price is not set then a message is to be rendered
  # instead.
  #
  # @param [Offer] offer The offer
  #
  # @return [String] Offer price in words
  def offer_value(offer = nil)
    fail ArgumentError, 'Offer required and must be an instance of Offer' unless offer.instance_of? Offer
    if offer.price.zero?
      t('offers.no_price')
    else
      "#{ h nice_decimal(offer.price) } #{ offer.unit }"
    end
  end
end
