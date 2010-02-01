module AuthenticatedSystem
  protected
    # Returns true or false if the person is logged in.
    # Preloads @current_person with the person model if they're logged in.
    def logged_in?
      current_person != :false
    end

    # Accesses the current person from the session.  Set it to :false if login fails
    # so that future calls do not hit the database.
    def current_person
      @current_person ||= (login_from_session || login_from_basic_auth || login_from_cookie || :false)
    end

    # Store the given person id in the session.
    def current_person=(new_person)
      session[:person_id] = (new_person.nil? || new_person.is_a?(Symbol)) ? nil : new_person.id 
      @current_person = new_person || :false
    end

    # Check if the person is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the person
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_person.login != "bob"
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
    # behavior in case the person is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          flash[:error] = "You must log in to access this page."
          redirect_to login_url
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

    # Inclusion hook to make #current_person and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_person, :logged_in?
    end

    # Called from #current_person.  First attempt to login by the person id stored in the session.
    def login_from_session
      self.current_person = Person.find(session[:person_id]) if session[:person_id]
    end

    # Called from #current_person.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_person = Person.authenticate(username, password)
      end
    end

    # Called from #current_person.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      person = cookies[:auth_token] && Person.find_by_remember_token(cookies[:auth_token])
      if person && person.remember_token?
        person.remember_me
        cookies[:auth_token] = { :value => person.remember_token, :expires => person.remember_token_expires_at }
        self.current_person = person
      end
    end
end
