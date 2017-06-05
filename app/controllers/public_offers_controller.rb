# frozen_string_literal: true

# Public Offers
class PublicOffersController < ActionController::Base
  helper :all

  def index
    @offers = Offer.all
  end

  def show
    @offer = Offer.find(params[:id])
  end
end
