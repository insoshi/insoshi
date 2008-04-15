# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include SharedHelper
  include PreferencesHelper
  
  before_filter :create_page_view, :require_activation, :tracker_vars

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
end