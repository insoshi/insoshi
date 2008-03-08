class ConnectionsController < ApplicationController
  
  before_filter :login_required
  
  def edit
    # TODO: verify connection/contact match
    @connection = Connection.find(params[:id])
    @contact    = Person.find(params[:person_id])
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
    @connection = Connection.find(params[:id])
    
    respond_to do |format|
      @connection.accept
      flash[:notice] = "Accepted connection with #{@connection.contact.name}"
      format.html { redirect_to(home_url) }
    end
  end

  def destroy
    @connection = Connection.find(params[:id])
    @connection.breakup
    
    respond_to do |format|
      flash[:success] = "Ended connection with #{@connection.contact.name}"
      format.html { redirect_to(home_url) }
    end
  end
end
