class PasswordRemindersController < ApplicationController
  
  def new
  end
  
  def create
    person = Person.find_by_email(params[:person][:email])
    respond_to do |format|
      format.html do
        if person.nil?
          flash.now[:error] = "Invalid email address"
          render :action => "new"
        else
          PersonMailer.deliver_password_reminder(person)
          flash[:success] = "Your password has been sent"
          redirect_to login_url
        end
      end
    end
  end
end
