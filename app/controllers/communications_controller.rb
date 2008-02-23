class CommunicationsController < ApplicationController
  # GET /communications
  # GET /communications.xml
  def index
    @communications = Communication.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @communications }
    end
  end

  # GET /communications/1
  # GET /communications/1.xml
  def show
    @communication = Communication.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @communication }
    end
  end

  # GET /communications/new
  # GET /communications/new.xml
  def new
    @communication = Communication.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @communication }
    end
  end

  # GET /communications/1/edit
  def edit
    @communication = Communication.find(params[:id])
  end

  # POST /communications
  # POST /communications.xml
  def create
    @communication = Communication.new(params[:communication])

    respond_to do |format|
      if @communication.save
        flash[:notice] = 'Communication was successfully created.'
        format.html { redirect_to(@communication) }
        format.xml  { render :xml => @communication, :status => :created, :location => @communication }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @communication.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /communications/1
  # PUT /communications/1.xml
  def update
    @communication = Communication.find(params[:id])

    respond_to do |format|
      if @communication.update_attributes(params[:communication])
        flash[:notice] = 'Communication was successfully updated.'
        format.html { redirect_to(@communication) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @communication.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /communications/1
  # DELETE /communications/1.xml
  def destroy
    @communication = Communication.find(params[:id])
    @communication.destroy

    respond_to do |format|
      format.html { redirect_to(communications_url) }
      format.xml  { head :ok }
    end
  end
end
