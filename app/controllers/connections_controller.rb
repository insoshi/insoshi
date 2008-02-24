class ConnectionsController < ApplicationController
  
  before_filter :login_required
  
  def create
    @contact = Person.find(params[:person_id])

    respond_to do |format|
      if Connection.request(current_person, @contact)
        flash[:notice] = 'Connection request sent!'
        format.html { redirect_to home_url }
      else
        # This should only happen when people do something funky
        # like friending themselves.
        flash[:notice] = "Invalid connection"
        format.html { redirect_to home_url }
      end
    end
  end

  # def update
  #   @connection = Connection.find(params[:id])
  # 
  #   respond_to do |format|
  #     if @connection.update_attributes(params[:connection])
  #       flash[:notice] = 'Connection was successfully updated.'
  #       format.html { redirect_to(@connection) }
  #       format.xml  { head :ok }
  #     else
  #       format.html { render :action => "edit" }
  #       format.xml  { render :xml => @connection.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end


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
