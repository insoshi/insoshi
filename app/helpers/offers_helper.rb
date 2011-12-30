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
end
