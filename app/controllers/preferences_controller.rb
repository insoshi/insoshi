class PreferencesController < ApplicationController
  # GET /preferences
  # GET /preferences.xml
  def index
    @preferences = Preference.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @preferences }
    end
  end

  # GET /preferences/1
  # GET /preferences/1.xml
  def show
    @preference = Preference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @preference }
    end
  end

  # GET /preferences/new
  # GET /preferences/new.xml
  def new
    @preference = Preference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @preference }
    end
  end

  # GET /preferences/1/edit
  def edit
    @preference = Preference.find(params[:id])
  end

  # POST /preferences
  # POST /preferences.xml
  def create
    @preference = Preference.new(params[:preference])

    respond_to do |format|
      if @preference.save
        flash[:notice] = 'Preference was successfully created.'
        format.html { redirect_to(@preference) }
        format.xml  { render :xml => @preference, :status => :created, :location => @preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /preferences/1
  # PUT /preferences/1.xml
  def update
    @preference = Preference.find(params[:id])

    respond_to do |format|
      if @preference.update_attributes(params[:preference])
        flash[:notice] = 'Preference was successfully updated.'
        format.html { redirect_to(@preference) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /preferences/1
  # DELETE /preferences/1.xml
  def destroy
    @preference = Preference.find(params[:id])
    @preference.destroy

    respond_to do |format|
      format.html { redirect_to(preferences_url) }
      format.xml  { head :ok }
    end
  end
end
