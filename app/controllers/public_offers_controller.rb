# frozen_string_literal: true

# Public Offers
class PublicOffersController < ApplicationController #ActionController::Base
  helper :all
  layout 'application'

  def index
    @offers = Offer.all
  end

  def show
    @offer = Offer.find(params[:id])
  end
end
