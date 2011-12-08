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
end
