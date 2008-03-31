class ConnectionsController < ApplicationController
  
  before_filter :login_required
  before_filter :authorize_view, :only => :index
  before_filter :authorize_person, :only => [:edit, :update, :destroy]
  
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
        flash[:notice] = 'Connection request sent!'
        format.html { redirect_to(home_url) }
      else
        # This should only happen when people do something funky
        # like friending themselves.
        flash[:notice] = "Invalid connection"
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
        flash[:notice] = %(Accepted connection with
                           <a href="#{person_url(contact)}">#{name}</a>)
      when "Decline"
        @connection.breakup
        flash[:notice] = "Declined connection with #{name}"
      end
      format.html { redirect_to(home_url) }
    end
  end

  def destroy
    @connection.breakup
    
    respond_to do |format|
      flash[:success] = "Ended connection with #{@connection.contact.name}"
      format.html { redirect_to(home_url) }
    end
  end

  private
  
    def authorize_view
      @person = Person.find(params[:person_id])
      unless (current_person?(@person) or
              Connection.connected?(@person, current_person))
        redirect_to home_url
      end
    end
  
    # Make sure the current person is correct for this connection.
    def authorize_person
      @connection = Connection.find(params[:id],
                                    :include => [:person, :contact])
      unless current_person?(@connection.person)
        flash[:error] = "Invalid connection."
        redirect_to home_url
      end
    end

end
