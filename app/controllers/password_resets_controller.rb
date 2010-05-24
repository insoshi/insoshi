class PasswordResetsController < ApplicationController
  before_filter :require_no_person
  before_filter :load_person_using_perishable_token, :only => [:edit,:update]
  before_filter :mailer_set_url_options

  def new
  end

  def create
    @person = Person.find_by_email(params[:email])
    if @person
      @person.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you"
      redirect_to root_path
    else
      flash[:error] = "No one was found with that email address"
      render :action => :new
    end
  end

  def edit
  end

  def update
    @person.password = params[:password]
    @person.password_confirmation = params[:password]
    if @person.save
      flash[:success] = "Your password was updated."
      redirect_to @person
    else
      render :action => :edit
    end
  end

  private

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def load_person_using_perishable_token
    @person = Person.find_using_perishable_token(params[:id])
    unless @person
      flash[:error] = "We're sorry, but we could not locate your account"
      redirect_to root_url
    end
  end
  
  def check_can_send_email
    unless global_prefs.can_send_email?
      flash[:error] = t('error_invalid_action')
      redirect_to home_url
    end
  end
end
