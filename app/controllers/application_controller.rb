# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include SharedHelper
  include PreferencesHelper

  helper_method :current_person
  helper_method :logged_in?
  helper_method :bootstrap_class

  before_filter :require_activation, :admin_warning,
                :set_person_locale,
                :set_theme

  around_filter :set_time_zone

  layout proc{ |c| c.request.xhr? ? false : "application" }

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    respond_to do |format|
      format.html do
        unless @group.nil?
          redirect_to @group
        else
          unless @person.nil?
            redirect_to @person
          else
            redirect_to index
          end
        end
      end
      format.js do
        canvas = case params[:controller] 
          when 'reqs','bids'
            'reqs_canvas'
          when 'offers'
            'offers_canvas'
          when 'exchanges'
            'people_canvas'
          else
            'home_canvas'
          end
        if request.xhr?
          render :partial => '/shared/flash_messages', :locals => {:canvas_id => canvas}
        else
          render :action => 'reject'
        end
      end
    end
  end

#  audit Req, Offer, Bid, Exchange, Account, Person, :only => [:create, :update, :destroy]

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '71a8c82e6d248750397d166001c5e308'

  protected
    def ajax_posts_per_page
      current_person.posts_per_page 
    end

    def bootstrap_class(flash_key)
      {notice: 'alert-success',
       success: 'alert-success',
       error: 'alert-error',
       alert: 'alert-info'}[flash_key] || ''
    end

    def logged_in?
      !!current_person
    end
    
    # User is back after some absence and he CAN'T go anywhere until they update their credit card data
    # only if they have monetary fee sign up and haven't already submitted credit card data.
    def credit_card_required
      if logged_in? and current_person.credit_card_required?
        redirect_to credit_card_path
      else return true
      end
    end
 
    # Checks if user entered credit card data, or if admin allowed him not to.
    # Even if admin allowed him not to put credit card data, he has to submit it
    # to create offer.
    def check_credit_card
      if logged_in? and current_person.stripe_id.blank? and current_person.fee_plan.contains_stripe_fees?
        store_location
        redirect_to credit_card_path
      else return true
      end
    end

    def login_required
      unless current_person
        store_location
        flash[:notice] = t('notice_login_required')
        redirect_to login_url
        return false
      end
    end

    def access_denied
      store_location
      flash[:notice] = t('notice_login_required')
      redirect_to login_url
      return false
    end

    def require_no_person
      if current_person
        store_location
        flash[:notice] = "You must be logged out to view this page"
        redirect_to root_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def current_person_session
      return @current_person_session if defined?(@current_person_session)
      @current_person_session = PersonSession.find
    end

    def current_person
      # login_or_oauth_required sets @current_person to nil
      return @current_person if defined?(@current_person) && @current_person
      @current_person = current_person_session && current_person_session.record
    end

    def current_person=(person)
      @current_person=person
    end

    def current_user
      current_person 
    end

    def current_ability
      @current_ability ||= Ability.new(current_person, current_token)
    end

    def set_theme
      if params[:theme]
        session[:theme] = params[:theme]
        uri = URI(request.url)
        new_params = CGI.parse(uri.query)
        new_params.delete('theme')
        uri.query = URI.encode_www_form(new_params)
        redirect_to uri.to_s.chomp('?')
      end
    end

    def set_person_locale
      if logged_in?
        I18n.locale = current_person.language
      else
        session[:locale] = params[:locale] if params[:locale]
        I18n.locale = session[:locale] || global_prefs.locale || I18n.default_locale
      end
    end

    def authorized?
      logged_in? and ( current_person.active? or current_person.admin? )
    end
  private

    def admin_required
      unless current_person.admin?
        flash[:error] = t("error_admin_access_required")
        redirect_to home_url
      end
    end
 
    # no longer used
    # Create a Scribd-style PageView.
    # See http://www.scribd.com/doc/49575/Scaling-Rails-Presentation
    def create_page_view
      if request.format.html?
        #PageView.create(:person_id => session[:person_id],
        #                :request_url => request.request_uri,
        #                :ip_address => request.remote_ip,
        #                :referer => request.env["HTTP_REFERER"],
        #                :user_agent => request.env["HTTP_USER_AGENT"])
      end
    end
 
    def require_activation
      if logged_in?
        unless current_person.active? or current_person.admin?
          redirect_to logout_url
        end
        # last_logged_in_at actually captures site activity, so update it now.
        current_person.touch :last_logged_in_at
      end
    end
    
    # Warn the admin if his email address or password is still the default.
    def admin_warning
      if request.format.html?
        default_domain = "example.com"
        default_password = "admin"
        if logged_in? and current_person.admin? and !(request.fullpath =~ /^\/admin/)
          if current_person.email =~ /@#{default_domain}$/
            flash[:notice] = %(#{t('notice_warning_your_email_address')} 
              #{default_domain}.
              <a href="#{edit_person_path(current_person)}">#{t('notice_change_it_here')}</a>.)
          end
        end
      end
    end

    # set timezone, only absolute format time will be affected
    def set_time_zone(&block)
      if current_user && current_user.time_zone
        Time.use_zone(current_user.time_zone, &block)
      else
        Time.use_zone(TimeZone.first.time_zone, &block)
      end
    end
end
