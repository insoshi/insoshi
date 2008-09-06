# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  skip_before_filter :require_activation, :only => [:new, :destroy]

  def new
    @body = "login single-col"
  end

  def create
    logger.warn "XXX openid_url: #{params[:openid_url]}"
    if using_open_id?
      open_id_authentication(params[:openid_url])
    else
      password_authentication(params[:email],params[:password])
    end
  end

  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if result.successful?
        @person = Person.find_or_initialize_by_identity_url(identity_url)
        if @person.new_record?
          @person.name = registration['nickname']
          @person.email = registration['email']
          # XXX for now, don't mess with email verification for openid guys
          @person.email_verified = true if global_prefs.email_verifications?
          @person.save
          if !@person.errors.empty?
            err_message = "Your OpenID profile must provide"
            err_message += " nickname," if !@person.errors[:name].nil?
            err_message += " email," if !@person.errors[:email].nil?

            failed_login err_message.chop
            return
          end
        end
        self.current_person = @person
        successful_login
      else
        failed_login result.message
      end
    end
  end

  def failed_login(message = "Authentication failed.")
    @body = "login single-col"
    flash.now[:error] = message
    render :action => 'new'
  end
  
  def successful_login
    if params[:remember_me] == "1"
      self.current_person.remember_me
      cookies[:auth_token] = { :value => self.current_person.remember_token , :expires => self.current_person.remember_token_expires_at }
    end
    redirect_back_or_default('/')
    flash[:notice] = "Logged in successfully"
  end

  def password_authentication(login, password)
    person = Person.authenticate(login, password)
    unless person.nil?
      if person.deactivated?
        flash[:error] = "Your account has been deactivated"
        redirect_to home_url and return
      elsif global_prefs.email_verifications? and 
            not person.email_verified? and not person.admin?
        flash[:notice] = %(Unverified email address. 
                           Please check your email for your activation code.)
        redirect_to login_url and return
      end
    end
    self.current_person = person
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
      flash[:success] = "Logged in successfully"
      if @first_admin_login
        redirect_to admin_preferences_url
      else
        redirect_back_or_default('/')
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
