class ReqsController < ApplicationController

  respond_to :html, :xml, :json, :js

  skip_before_filter :require_activation, :only => [:show, :index]
  before_filter :login_required, :except => [:show, :index]
  before_filter :credit_card_required, :except => [:show, :index]
  before_filter :login_or_oauth_required, :only => [:show, :index]
  load_resource :group
  load_and_authorize_resource :req, :through => :group, :shallow => true

  # GET /reqs
  # GET /reqs.xml
  def index
    @selected_category = params[:category_id].nil? ? nil : Category.find(params[:category_id])
    @selected_neighborhood = params[:neighborhood_id].nil? ? nil : Neighborhood.find(params[:neighborhood_id])

    @authorized = @group.authorized_to_view_reqs?(current_person)
    if @authorized
      @reqs = Req.custom_search(@selected_neighborhood || @selected_category,
                              @group,
                              active=params[:scope].nil?, # if a scope is not passed, just return actives
                              params[:page],
                              ajax_posts_per_page,
                              params[:search]
                              ).order("reqs.updated_at desc")
    else
      flash[:notice] = t('notice_member_to_view_requests')
      @reqs = Req.where('1=0').paginate(:page => 1, :per_page => ajax_posts_per_page)
    end

    respond_with @reqs do |format|
      format.js {render :action => 'reject' if not request.xhr?}
    end
  end

  # GET /reqs/1
  # GET /reqs/1.xml
  def show
    @req = Req.find(params[:id])
    @bid = Bid.new
    @bid.estimated_hours = @req.estimated_hours
    @group = @req.group

    unless Membership.exist?(current_person,@req.group)
      flash[:notice] = t('notice_bid_requires_membership')
    end

    if @group.authorized_to_view_reqs?(current_person)
      respond_with @req do |format|
        format.js {render :action => 'reject' if not request.xhr?}
      end
    else
      raise CanCan::AccessDenied.new("Not authorized!", :read, Req)
    end
  end

  # GET /reqs/new
  def new
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name
    @selected_neighborhoods = current_person.neighborhoods
    @photo = @req.photos.build
    respond_to do |format|
      format.js {render :action => 'reject' if not request.xhr?}
      format.html { redirect_to group_path(@group, :anchor => 'reqs/new') }
    end
  end

  # GET /reqs/1/edit
  def edit
    @req = Req.find(params[:id])
    @group = @req.group
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name
    @photo = @req.photos.build if @req.photos.blank?

    respond_to do |format|
      format.js {render :action => 'reject' if not request.xhr?}
    end
  end

  # POST /reqs
  # POST /reqs.xml
  def create
    #@req = Req.new(params[:req])
    @req.group = @group
    @req.person = current_person

    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name

    respond_to do |format|
      if @req.save
        @reqs = Req.custom_search(nil,@group,active=true,page=1,ajax_posts_per_page,nil).order("updated_at desc")
        flash[:notice] = t('success_request_created')
        #respond_with @req
        #format.html { redirect_to(@req) }
        format.js
        format.xml  { head :ok }
      else
        @photo = @req.photos.build if @req.photos.blank?
        format.html { render :action => "new" }
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
    @all_categories = Category.by_long_name
    @all_neighborhoods = Neighborhood.by_long_name

    respond_to do |format|
      if @req.update_attributes(params[:req])
        flash[:notice] = t('notice_request_updated')
        @reqs = Req.custom_search(nil,@group,active=true,page=1,ajax_posts_per_page,nil).order("updated_at desc")
        format.html { redirect_to(@req) }
        format.js
        format.xml  { head :ok }
      else
        @photo = @req.photos.build if @req.photos.blank?
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

  def deactivate
    @req = Req.find(params[:id])
    if can?(:deactivate, @req)
      flash[:notice] = t('success_request_deactivated')
      @req.deactivate
    end
    respond_to do |format|
      format.js
    end
  end
end
