# This controller handles the login/logout function of the site.
class PersonSessionsController < ApplicationController

  skip_before_filter :require_activation, :only => [:new, :destroy]

  def new
    @person_session = PersonSession.new
    @body = "login single-col"
  end


  def create
    @person_session = PersonSession.new(params[:person_session])
    @person_session.save do |result|
      if result
        unless params[:person_session].nil?
          logger.info "OSC LOGIN SUCCESS: #{params[:person_session][:email]} from #{request.remote_ip}"
        end
        redirect_back_or_default root_url
      end
    end
    if !performed?
      #flash[:error] = t('error_authentication_failed')
      unless params[:person_session].nil?
        logger.info "OSC LOGIN FAILURE: #{params[:person_session][:email]} from #{request.remote_ip}"
      end
      @body = "login single-col"
      render :action => 'new'
    end
  end

  def destroy
    unless @current_person_session.nil?
      @current_person_session.destroy
      flash[:success] = t('success_logout')
    else
      flash[:error] = t('error_already_logged_out')
    end
    custom_logout_url = global_prefs.logout_url.empty? ? root_url : global_prefs.logout_url
    redirect_back_or_default custom_logout_url
  end
end
