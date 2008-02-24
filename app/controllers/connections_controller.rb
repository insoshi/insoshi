class ConnectionsController < ApplicationController
  
  before_filter :login_required
  
  def create
    @contact = Person.find(params[:person_id])

    respond_to do |format|
      if Connection.request(current_person, @contact)
        flash[:success] = 'Connection request sent!'
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
    @contact = Person.find(params[:person_id])
    Connection.accept(current_person, @contact)
    
    respond_to do |format|
      flash[:success] = "Accepted connection with #{@contact.name}"
      format.html { redirect_to(home_url) }
    end
  end


  # def destroy
  #   @connection = Connection.find(params[:id])
  #   @connection.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to(connections_url) }
  #     format.xml  { head :ok }
  #   end
  # end
end
