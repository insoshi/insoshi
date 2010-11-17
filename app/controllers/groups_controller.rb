class GroupsController < ApplicationController
  load_and_authorize_resource
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required
  
  def index
    # XXX can't define abilities w/ blocks (accessible_by) http://github.com/ryanb/cancan/wiki/Upgrading-to-1.4
    @groups = Group.name_sorted_and_paginated(params[:page])

    respond_to do |format|
      format.html
    end
  end

  def new_req
    @req = Req.new
    @all_categories = Category.all

    respond_to do |format|
      format.js
    end
  end

  def create_req
    @req = Req.new(params[:req])
    @req.group = @group

    if @req.due_date.blank?
      @req.due_date = 7.days.from_now
    else
      @req.due_date += 1.day - 1.second # make due date at end of day
    end
    @req.person_id = current_person.id

    respond_to do |format|
      if @req.save
        flash[:notice] = 'Request was successfully created.'
        @reqs = @group.reqs.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
        format.js
      else
        @all_categories = Category.all
        format.js {render :action => 'new_req'}
      end
    end
  end

  def new_offer
    @offer = Offer.new
    @all_categories = Category.all

    respond_to do |format|
      format.js
    end
  end

  def create_offer
    @offer = Offer.new(params[:offer])
    @offer.group = @group
    ##TODO: move this to the model, a before_create method?
    @offer.available_count = @offer.total_available
    @offer.person_id = current_person.id

    respond_to do |format|
      if @offer.save
        flash[:notice] = 'Offer was successfully created.'
        @offers = @group.offers.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
        format.js
      else
        @all_categories = Category.all
        format.js {render :action => 'new_offer'}
      end
    end
  end

  def show_default
    redirect_to group_path(current_person.default_group)
  end

  def show
    @forum = @group.forum
    @topics = Topic.find_recently_active(@forum, params[:page]) 
    @reqs = @group.reqs.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
    @offers = @group.offers.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
    @exchanges = @group.exchanges.paginate(:page => params[:page], :per_page => AJAX_POSTS_PER_PAGE)
    if Membership.exists?(current_person,@group)
      @add_membership_display = 'hide'
      @membership_display = ''
    else
      @add_membership_display = ''
      @membership_display = 'hide'
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @group.to_xml(:methods => [:icon,:thumbnail], :only => [:id,:name,:description,:mode,:person_id,:created_at,:updated_at,:unit,:icon,:thumbnail]) }
    end

  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def create
    @group.owner = current_person

    respond_to do |format|
      if @group.save
        flash[:success] = t('success_group_created')
        format.html { redirect_to(group_path(@group)) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = t('notice_group_updated')
        format.html { redirect_to(group_path(@group)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @group.destroy

    respond_to do |format|
      flash[:success] = t('success_group_deleted')
      format.html { redirect_to(groups_path) }
    end
  end
  
  def members
    @memberships = @group.memberships.paginate(:page => params[:page],
                                          :conditions => ['status = ?', Membership::ACCEPTED],
                                          :include => :person,
                                          :per_page => RASTER_PER_PAGE)

    @pending = @group.pending_request.paginate(:page => params[:page],
                                          :per_page => RASTER_PER_PAGE)
    respond_to do |format|
      format.html
    end
  end

  def photos
    #@group = Group.find(params[:id])
    @photos = @group.photos
    respond_to do |format|
      format.html
    end
  end
  
  def new_photo
    respond_to do |format|
      format.html
    end
  end
  
  def save_photo
    #group = Group.find(params[:id])
    if params[:photo].nil?
      # This is mainly to prevent exceptions on iPhones.
      flash[:error] = t('error_browser_upload_fail')
      redirect_to(edit_group_path(@group)) and return
    end
    if params[:commit] == "Cancel"
      flash[:notice] = t('notice_upload_canceled')
      redirect_to(edit_group_path(@group)) and return
    end
    
    group_data = { :group => @group,
                    :primary => @group.photos.empty? }
    @photo = Photo.new(params[:photo].merge(group_data))
    
    respond_to do |format|
      if @photo.save
        flash[:success] = t('success_photo_uploaded')
        if @group.owner == current_person
          format.html { redirect_to(edit_group_path(@group)) }
        else
          format.html { redirect_to(group_path(@group)) }
        end
      else
        format.html { render :action => "new_photo" }
      end
    end
  end
  
  def delete_photo
    @group = Group.find(params[:id])
    @photo = Photo.find(params[:photo_id])
    @photo.destroy
    flash[:success] = t('success_photo_deleted_for_group') + " '#{@group.name}'"
    respond_to do |format|
      format.html { redirect_to(edit_group_path(@group)) }
    end
  end
  
  private
  
  def group_owner
    redirect_to home_url unless current_person == Group.find(params[:id]).owner
  end
  
end
