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
        flash[:notice] = t('notice_logged_in_successfully')
        redirect_back_or_default root_url
      end
    end
    if !performed?
      #flash[:error] = t('error_authentication_failed')
      @body = "login single-col"
      render :action => 'new'
    end
  end

  def destroy
    @current_person_session.destroy
    flash[:notice] = "Log out successful!"
    redirect_back_or_default root_url
  end
end
