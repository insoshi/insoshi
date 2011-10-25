class ReqsController < ApplicationController
  skip_before_filter :require_activation, :only => [:show, :index]
  before_filter :login_required, :except => [:show, :index]
  before_filter :login_or_oauth_required, :only => [:show, :index]
  load_resource :group
  load_and_authorize_resource :req, :through => :group, :shallow => true
  before_filter :correct_person_and_no_accept_required, :only => [ :edit, :update ]
  before_filter :correct_person_and_no_commitment_required, :only => [ :destroy ]

  # GET /reqs
  # GET /reqs.xml
  def index
=begin
    if params[:filter]
      if "all" == params[:filter]
        @reqs = Req.all_active(params[:page])
      else
        @reqs = Req.current_and_active(params[:page])
      end
    else
      @reqs = Req.current_and_active(params[:page])
    end
=end
    @selected_category = params[:category_id].nil? ? nil : Category.find(params[:category_id])
    @selected_neighborhood = params[:neighborhood_id].nil? ? nil : Neighborhood.find(params[:neighborhood_id])

    @reqs = Req.search(@selected_neighborhood || @selected_category, 
                       @group, 
                       params[:page], 
                       AJAX_POSTS_PER_PAGE,
                       params[:search]
                       )

    respond_to do |format|
      format.js
      # format.html # index.html.erb
      format.xml  { render :xml => @reqs }
    end
  end

  # GET /reqs/1
  # GET /reqs/1.xml
  def show
    @req = Req.find(params[:id])
    @bid = Bid.new
    @bid.estimated_hours = @req.estimated_hours

    unless @req.group.nil?
      if logged_in?
        unless Membership.exist?(current_person,@req.group)
          flash[:notice] = t('notice_bid_requires_membership')
        end
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @req }
      format.js
    end
  end

  # GET /reqs/new
  # GET /reqs/new.xml
  def new
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }

    respond_to do |format|
      format.js
      format.xml  { render :xml => @req }
    end
  end

  # GET /reqs/1/edit
  def edit
    @req = Req.find(params[:id])
    @group = @req.group
    @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
    @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }

    respond_to do |format|
      format.js
    end
  end

  # POST /reqs
  # POST /reqs.xml
  def create
    #@req = Req.new(params[:req])
    @req.group = @group

    if @req.due_date.blank?
      @req.due_date = 7.days.from_now
    else
      @req.due_date += 1.day - 1.second # make due date at end of day
    end
    @req.person = current_person

    respond_to do |format|
      if @req.save
        flash[:notice] = t('success_request_created')
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @reqs = @group.reqs.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
        format.js
        format.xml  { render :xml => @req, :status => :created, :location => @req }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.js { render :action => "new" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reqs/1
  # PUT /reqs/1.xml
  def update
    @req = Req.find(params[:id])
    @group = @req.group

    respond_to do |format|
      if @req.update_attributes(params[:req])
        flash[:notice] = t('notice_request_updated')
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @reqs = @group.reqs.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
        format.html { redirect_to(@req) }
        format.js
        format.xml  { head :ok }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        @all_neighborhoods = Neighborhood.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "edit" }
        format.js { render :action => "edit" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reqs/1
  # DELETE /reqs/1.xml
  def destroy
    @req = Req.find(params[:id])
    if can?(:destroy, @req)
      flash[:notice] = t('success_request_destroyed')
      @req.destroy
    else
      flash[:error] = t('error_request_cannot_be_deleted')
    end

    respond_to do |format|
      format.html { redirect_to(reqs_url) }
      format.xml  { head :ok }
      format.js
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
    redirect_to home_url if request.has_commitment? || request.has_approved?
  end
end
