class Admin::PreferencesController < ApplicationController
  
  before_filter :login_required, :admin_required
  before_filter :setup
  
  in_place_edit_for :post, :app_name
  
  def index
    render :action => "show"
  end
  
  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      old_preferences = @preferences.clone
      if @preferences.update_attributes(params[:preferences])
        if (not old_preferences.email_verifications? and 
            @preferences.email_verifications?)
          # Email verifications have been turned on.
          # We have to mark all the email addresses as verified for the
          # require_activation before filter to work.
          Person.transaction do
            Person.find(:all).each do |person|
              person.email_verified = true
              person.save
            end
          end
        end
        flash[:success] = 'Preferences successfully updated.'
        if server_restart?(old_preferences)
          flash[:error] = 'Restart the server to activate the changes'
        end
        format.html { redirect_to admin_preferences_url }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private
    
    def setup
      @preferences = Preference.find(:first)
    end
    
    # The server needs to be restarted if the email settings change.
    def server_restart?(old_preferences)
      old_preferences.smtp_server  != @preferences.smtp_server or 
      old_preferences.domain != @preferences.domain or
      old_preferences.server_name != @preferences.server_name or
      old_preferences.email_notifications != @preferences.email_notifications
    end
end
