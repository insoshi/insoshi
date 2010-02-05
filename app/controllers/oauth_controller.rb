require 'oauth/controllers/provider_controller'

class OauthController < ApplicationController
#  skip_before_filter :create_page_view
  skip_before_filter :require_activation
  skip_before_filter :admin_warning
 
  include OAuth::Controllers::ProviderController

  # Override this to match your authorization page form
  # It currently expects a checkbox called authorize
  # def user_authorizes_token?
  #   params[:authorize] == '1'
  # end

end
