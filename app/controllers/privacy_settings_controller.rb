class PrivacySettingsController < ApplicationController
  before_filter :login_required, :credit_card_required
  load_and_authorize_resource

  def update
    respond_to do |format|
      if @privacy_setting.update_attributes(params[:privacy_setting])
        flash[:notice] = t('notice_privacy_settings_updated')
        format.js
      else
        flash[:error] = t('error_invalid_action')
        format.js
      end
    end
  end
end
