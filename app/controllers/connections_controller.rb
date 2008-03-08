class ConnectionsController < ApplicationController
  
  before_filter :login_required
  before_filter :authorize_person, :except => :create
  
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
      case params[:commit]
      when "Accept"
        @connection.accept
        flash[:notice] = "Accepted connection with #{@connection.contact.name}"
      when "Decline"
        @connection.breakup
        flash[:notice] = "Declined connection with #{@connection.contact.name}"
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
