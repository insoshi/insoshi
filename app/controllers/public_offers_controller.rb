# frozen_string_literal: true

# Public Offers
class PublicOffersController < ApplicationController
  skip_before_filter :require_activation

  def index
    @offers = Offer
                .active
                .includes(:person)
                .where(people: { deactivated: false })
                .order('offers.id desc')
    @offers = @offers.paginate(page: params[:page], per_page: 100)
  end

  def show
    @offer = Offer.find(params[:id])
    @url = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  end
end
