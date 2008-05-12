# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  skip_before_filter :require_activation, :only => [:new, :destroy]

  def new
    @body = "login single-col"
  end

  def create
    self.current_person = Person.authenticate(params[:email],
                                              params[:password])
    if logged_in?
      # First admin logins should forward to preferences
      if current_person.last_logged_in_at.nil? and current_person.admin?
        @first_admin_login = true
      end
      current_person.last_logged_in_at = Time.now
      current_person.save!
      if params[:remember_me] == "1"
        self.current_person.remember_me
        cookies[:auth_token] = {
          :value => self.current_person.remember_token,
          :expires => self.current_person.remember_token_expires_at }
      end
      if current_person.deactivated?
        destroy
      else
        flash[:success] = "Logged in successfully"
        if @first_admin_login
          redirect_to admin_preferences_url
        else
          redirect_back_or_default('/')
        end
      end
    else
      @body = "login single-col"
      flash.now[:error] = "Invalid email/password combination"
      params[:password] = nil
      render :action => 'new'
    end
  end

  def destroy
    self.current_person.forget_me if logged_in?
    cookies.delete :auth_token
    if logged_in? and current_person.deactivated?
      reset_session
      flash[:error] = "Your account is inactive."
      redirect_to login_url
    else
      reset_session
      flash[:success] = "You have been logged out."
      redirect_back_or_default(login_url)
    end
  end
end
