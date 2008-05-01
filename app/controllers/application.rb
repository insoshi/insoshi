# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include SharedHelper
  include PreferencesHelper
  
  before_filter :create_page_view, :require_activation, :tracker_vars,
                :admin_warning

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '71a8c82e6d248750397d166001c5e308'

  private

    def admin_required
      unless current_person.admin?
        flash[:error] = "Admin access required"
        redirect_to home_url
      end
    end
  
    # Create a Scribd-style PageView.
    # See http://www.scribd.com/doc/49575/Scaling-Rails-Presentation
    def create_page_view
      PageView.create(:user_id => session[:user_id],
                      :request_url => request.request_uri,
                      :session => session,
                      :ip_address => request.remote_ip,
                      :referer => request.env["HTTP_REFERER"],
                      :user_agent => request.env["HTTP_USER_AGENT"])
    end
  
    def require_activation
      if logged_in? and current_person.deactivated? and !current_person.admin?
        redirect_to logout_url
      end
    end
    
    # A tracker to tell us about the activity of Insoshi installs.
    def tracker_vars
      @tracker_id = File.open("identifier").read rescue nil
      @env = ENV['RAILS_ENV']
    end
    
    # Warn the admin if his email address or password is still the default.
    def admin_warning
      default_domain = "example.com"
      default_password = "admin"
      if logged_in? and current_person.admin? 
        if current_person.email =~ /@#{default_domain}$/
          flash[:notice] = %(Warning: your email address is still at 
            #{default_domain}.
            <a href="#{edit_person_path(current_person)}">Change it here</a>.)
        end
        if current_person.unencrypted_password == default_password
          flash[:error] = %(Warning: your password is still the default.
            <a href="#{edit_person_path(current_person)}">Change it here</a>.)          
        end
      end
    end
end