class ReqsController < ApplicationController
  before_filter :login_required, :only => [ :new, :edit, :create, :update ]

  # GET /reqs
  # GET /reqs.xml
  def index
    @reqs = Req.find(:all, :order => 'created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reqs }
    end
  end

  # GET /reqs/1
  # GET /reqs/1.xml
  def show
    @req = Req.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/new
  # GET /reqs/new.xml
  def new
    @req = Req.new
    @all_categories = Category.find(:all, :order => "parent_id, name")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/1/edit
  def edit
    @req = Req.find(params[:id])
  end

  # POST /reqs
  # POST /reqs.xml
  def create
    @req = Req.new(params[:req])

    @req.person_id = current_person.id

    respond_to do |format|
      if @req.save
        flash[:notice] = 'Request was successfully created.'
        format.html { redirect_to(@req) }
        format.xml  { render :xml => @req, :status => :created, :location => @req }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reqs/1
  # PUT /reqs/1.xml
  def update
    @req = Req.find(params[:id])

    respond_to do |format|
      if @req.update_attributes(params[:req])
        flash[:notice] = 'Request was successfully updated.'
        format.html { redirect_to(@req) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reqs/1
  # DELETE /reqs/1.xml
  def destroy
    @req = Req.find(params[:id])
    @req.destroy

    respond_to do |format|
      format.html { redirect_to(reqs_url) }
      format.xml  { head :ok }
    end
  end
end
