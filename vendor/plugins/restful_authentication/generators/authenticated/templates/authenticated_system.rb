module AuthenticatedSystem
  protected
    # Returns true or false if the <%= file_name %> is logged in.
    # Preloads @current_<%= file_name %> with the <%= file_name %> model if they're logged in.
    def logged_in?
      current_<%= file_name %> != :false
    end

    # Accesses the current <%= file_name %> from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_<%= file_name %>
      @current_<%= file_name %> ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
    end

    # Store the given <%= file_name %> id in the session.
    def current_<%= file_name %>=(new_<%= file_name %>)
      session[:<%= file_name %>_id] = (new_<%= file_name %>.nil? || new_<%= file_name %>.is_a?(Symbol)) ? nil : new_<%= file_name %>.id
      @current_<%= file_name %> = new_<%= file_name %> || :false
    end

    # Check if the <%= file_name %> is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the <%= file_name %>
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_<%= file_name %>.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the <%= file_name %> is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_<%= controller_singular_name %>_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_<%= file_name %> and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_<%= file_name %>, :logged_in?
    end

    # Called from #current_<%= file_name %>.  First attempt to login by the <%= file_name %> id stored in the session.
    def login_from_session
      self.current_<%= file_name %> = <%= class_name %>.find(session[:<%= file_name %>_id]) if session[:<%= file_name %>_id]
    end

    # Called from #current_<%= file_name %>.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_<%= file_name %> = <%= class_name %>.authenticate(username, password)
      end
    end

    # Called from #current_<%= file_name %>.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      <%= file_name %> = cookies[:auth_token] && <%= class_name %>.find_by_remember_token(cookies[:auth_token])
      if <%= file_name %> && <%= file_name %>.remember_token?
        <%= file_name %>.remember_me
        cookies[:auth_token] = { :value => <%= file_name %>.remember_token, :expires => <%= file_name %>.remember_token_expires_at }
        self.current_<%= file_name %> = <%= file_name %>
      end
    end
end
