class PasswordRemindersController < ApplicationController

  before_filter :check_can_send_email
  
  def new
  end
  
  def create
    person = Person.find_by_email(params[:person][:email])
    respond_to do |format|
      format.html do
        if person.nil?
          flash[:error] = t('error_invalid_email_address')
          render :action => "new"
        else
          PersonMailer.deliver_password_reminder(person)
          flash[:success] = t('success_your_password_has_been_sent')
          redirect_to login_url
        end
      end
    end
  end

  private
  
    def check_can_send_email
      unless global_prefs.can_send_email?
        flash[:error] = t('error_invalid_action')
        redirect_to home_url
      end
    end
end
