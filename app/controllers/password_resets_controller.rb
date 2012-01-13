class PasswordResetsController < ApplicationController
  before_filter :require_no_person
  before_filter :load_person_using_perishable_token, :only => [:edit,:update]

  def new
  end

  def create
    @person = Person.find_by_email(params[:email])
    if @person
      @person.deliver_password_reset_instructions!
      flash[:notice] = t('notice_password_instructions_emailed')
      redirect_to root_path
    else
      flash[:error] = t('error_email_not_found')
      render :action => :new
    end
  end

  def edit
  end

  def update
    @person.password = params[:password]
    @person.password_confirmation = params[:password]
    if @person.save
      flash[:success] = t('success_password_updated')
      redirect_to @person
    else
      render :action => :edit
    end
  end

  private

  def load_person_using_perishable_token
    @person = Person.find_using_perishable_token(params[:id])
    unless @person
      flash[:error] = t('error_account_locate')
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
