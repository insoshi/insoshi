class ConnectionsController < ApplicationController
  
  before_filter :login_required, :setup
  before_filter :authorize_view, :only => :index
  before_filter :authorize_person, :only => [:edit, :update, :destroy]
  before_filter :redirect_for_inactive, :only => [:edit, :update]
  
  # Show all the contacts for a person.
  def index
    @contacts = @person.contacts.paginate(:page => params[:page],
                                          :per_page => RASTER_PER_PAGE)
  end
  
  def edit
    @contact = @connection.contact
  end
  
  def create
    @contact = Person.find(params[:person_id])

    respond_to do |format|
      if Connection.request(current_person, @contact)
        flash[:success] = t('success_connection_request_sent')
        format.html { redirect_to(home_url) }
      else
        # This should only happen when people do something funky
        # like friending themselves.
        flash[:error] = t('error_connection_invalid')
        format.html { redirect_to(home_url) }
      end
    end
  end

  def update
    
    respond_to do |format|
      contact = @connection.contact
      name = contact.name
      case params[:commit]
      when "Accept"
        @connection.accept
        flash[:notice] = t('notice_connection_accepted') + " " +
                           %(<a href="#{person_url(contact)}">#{name}</a>)
      when "Decline"
        @connection.breakup
        flash[:notice] = t('notice_connection_declined') + " #{name}"
      end
      format.html { redirect_to(home_url) }
    end
  end

  def destroy
    @connection.breakup
    
    respond_to do |format|
      flash[:success] = t('success_connection_ended') + " #{@connection.contact.name}"
      format.html { redirect_to( person_connections_url(current_person)) }
    end
  end

  private

    def setup
      # Connections have same body class as profiles.
      @body = "profile"
    end

    def authorize_view
      @person = Person.find(params[:person_id])
      unless (current_person?(@person) or
              Connection.connected_to?(@person, current_person))
        redirect_to home_url
      end
    end
  
    # Make sure the current person is correct for this connection.
    def authorize_person
      @connection = Connection.find(params[:id],
                                    :include => [:person, :contact])
      unless current_person?(@connection.person)
        flash[:error] = t('error_connection_invalid')
        redirect_to home_url
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = t('error_connection_request_invalid_or_expired')
      redirect_to home_url
    end
    
    # Redirect if the target person is inactive.
    # Suppose Alice sends Bob a connection request, but then the admin 
    # deactivates Alice.  We don't want Bob to be able to make the connection.
    def redirect_for_inactive
      if @connection.contact.deactivated?
        flash[:error] = t('error_connection_request_person_deactivated')
        redirect_to home_url
      end
    end

end
