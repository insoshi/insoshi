class ReqsController < ApplicationController
  skip_before_filter :require_activation, :only => [:show, :index]
  before_filter :login_required, :except => [:show, :index]
  before_filter :login_or_oauth_required, :only => [:show, :index]
  before_filter :correct_person_and_no_accept_required, :only => [ :edit, :update ]
  before_filter :correct_person_and_no_commitment_required, :only => [ :destroy ]

  # GET /reqs
  # GET /reqs.xml
  def index
    if params[:filter]
      if "all" == params[:filter]
        @reqs = Req.all_active(params[:page])
      else
        @reqs = Req.current_and_active(params[:page])
      end
    else
      @reqs = Req.current_and_active(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reqs }
    end
  end

  # GET /reqs/1
  # GET /reqs/1.xml
  def show
    @req = Req.find(params[:id])
    @bid = Bid.new
    @bid.estimated_hours = @req.estimated_hours

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/new
  # GET /reqs/new.xml
  def new
    @req = Req.new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/1/edit
  def edit
    @req = Req.find(params[:id])
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
  end

  # POST /reqs
  # POST /reqs.xml
  def create
    @req = Req.new(params[:req])

    if @req.due_date.blank?
      @req.due_date = 7.days.from_now
    else
      @req.due_date += 1.day - 1.second # make due date at end of day
    end
    @req.person_id = current_person.id

    respond_to do |format|
      if @req.save
        flash[:success] = t('success_request_created')
        format.html { redirect_to(@req) }
        format.xml  { render :xml => @req, :status => :created, :location => @req }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "new" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reqs/1
  # PUT /reqs/1.xml
  def update
    @req = Req.find(params[:id])

#    @req.person_id = current_person.id

    respond_to do |format|
      if @req.update_attributes(params[:req])
        flash[:notice] = t('notice_request_updated')
        format.html { redirect_to(@req) }
        format.xml  { head :ok }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
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

  private

  def correct_person_and_no_accept_required
    request = Req.find(params[:id])
    redirect_to home_url unless request.person == current_person
    redirect_to home_url if request.has_accepted_bid?
  end

  def correct_person_and_no_commitment_required
    request = Req.find(params[:id])
    redirect_to home_url unless request.person == current_person
    redirect_to home_url if request.has_commitment? || request.has_approved?
  end
end
