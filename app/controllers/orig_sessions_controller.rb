# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  skip_before_filter :require_activation, :only => [:new, :destroy]

  def new
    @body = "login single-col"
  end

  def create
    if using_open_id?
      open_id_authentication(params[:openid_url])
    else
      # Protect against bots hitting us.
      if params[:email].nil? or params[:password].nil?
        render :text => "" and return
      end
      password_authentication(params[:email], params[:password])
    end
  end

  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :email]) do |result, identity_url, registration|
      if !result.successful?
        failed_login result.message
      else
        @person = Person.find_or_initialize_by_identity_url(identity_url)
        if @person.new_record?
          @person.email_verified = false if global_prefs.email_verifications?
          @person.name = registration['nickname']
          @person.email = registration['email']

          @person.save
          if !@person.errors.empty?
            err_message = t('error_openid_problems') + "<br>"
            @person.errors.each do |attr,val|
              logger.warn "open_id_authentication() Error: #{attr}:#{val}"
              err_message += "#{attr}: #{val}<br>"
            end
 
            flash[:error] = err_message.chop
            @body = "login single-col"
            session[:verified_identity_url] = identity_url
            render :partial => "shared/personal_details.html.erb", :object => @person, :layout => 'application'
          elsif global_prefs.email_verifications?
            @person.email_verifications.create
            flash[:notice] = t('notice_thanks_for_signing_up_check_email')
            redirect_to(home_url)
          else
            successful_login("Thanks for signing up!")
          end

          return
        end # if new record

        if @person.deactivated?
          flash[:error] = t('error_deactivated_account')
          redirect_to home_url and return
        end

        successful_login
      end
    end
  end

  def failed_login(message = t('error_authentication_failed'))
    @body = "login single-col"
    flash[:error] = message
    render :action => 'new'
  end
  
  def successful_login(message = t('notice_logged_in_successfully'))
    self.current_person = @person
    if params[:remember_me] == "1"
      current_person.remember_me
      cookies[:auth_token] = {
        :value => current_person.remember_token,
        :expires => current_person.remember_token_expires_at }
    end
    redirect_back_or_default('/')
    flash[:notice] = message
  end

  def password_authentication(login, password)
    person = Person.authenticate(login, password)
    unless person.nil?
      if person.deactivated?
        flash[:error] = t('error_your_account_is_deactivated') + "<br />" + t('error_membership_is_approved_after') + "<a href='/steps'>" + t('error_membership_here') + "</a>.<br />" + t('error_you_can_also') + " <a href='/contact'>" + t('error_contact') + " </a> " + t('error_the_administrators')
        redirect_to home_url and return
      elsif global_prefs.email_verifications? and 
            not person.email_verified? and not person.admin?
        flash[:notice] = t('notice_unverified_email_address')
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
        current_person.remember_me
        cookies[:auth_token] = {
          :value => current_person.remember_token,
          :expires => current_person.remember_token_expires_at }
      end
      flash[:success] = t('notice_logged_in_successfully')
      if @first_admin_login
        redirect_to admin_preferences_url
      else
        redirect_back_or_default('/')
      end
    else
      @body = "login single-col"
      flash[:error] = t('error_invalid_email_password')
      params[:password] = nil
      render :action => 'new'
    end
  end

  def destroy
    current_person.forget_me if logged_in?
    cookies.delete :auth_token
    if logged_in? and current_person.deactivated?
      reset_session
      flash[:error] = t('error_your_account_is_inactive')
      redirect_to login_url
    else
      reset_session
      flash[:success] = t('success_you_have_been_logged_out')
      redirect_back_or_default(login_url)
    end
  end
end
