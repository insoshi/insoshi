# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_filter :require_activation, :only => [:new, :destroy]

  def new
  end

  def create
    self.current_person = Person.authenticate(params[:email],
                                              params[:password])
    if logged_in?
      current_person.last_logged_in_at = Time.now
      current_person.save!
      if params[:remember_me] == "1"
        self.current_person.remember_me
        cookies[:auth_token] = { 
          :value => self.current_person.remember_token, 
          :expires => self.current_person.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:success] = "Logged in successfully"
    else
      flash[:error] = "Invalid email/password combination"
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
