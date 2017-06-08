# frozen_string_literal: true

# Public Offers
class PublicOffersController < ApplicationController
  skip_before_filter :require_activation

  def index
    @offers = Offer
              .order('offers.id desc')
              .paginate(page: params[:page], per_page: 16)
  end

  def show
    @offer = Offer.find(params[:id])
  end
end
