class GroupsController < ApplicationController
  skip_before_filter :require_activation
  before_filter :login_or_oauth_required
  before_filter :group_owner, :only => [:edit, :update, :destroy, 
    :new_photo, :save_photo, :delete_photo]
  
  def index
    @groups = Group.not_hidden(params[:page])

    respond_to do |format|
      format.html
    end
  end

  def new_req
    @group = Group.find(params[:id])
    @req = Req.new
    @all_categories = Category.all

    respond_to do |format|
      format.js
    end
  end

  def create_req
    @group = Group.find(params[:id])
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
        format.js
      else
        @all_categories = Category.all
        format.js {render :action => 'new_req'}
      end
    end
  end

  def new_offer
    @group = Group.find(params[:id])
    @offer = Offer.new
    @all_categories = Category.all

    respond_to do |format|
      format.js
    end
  end

  def create_offer
    @group = Group.find(params[:id])
    @offer = Offer.new(params[:offer])
    @offer.group = @group
    ##TODO: move this to the model, a before_create method?
    @offer.available_count = @offer.total_available
    @offer.person_id = current_person.id

    respond_to do |format|
      if @offer.save
        flash[:notice] = 'Offer was successfully created.'
        format.js
      else
        @all_categories = Category.all
        format.js {render :action => 'new_offer'}
      end
    end
  end

  def show
    @group = Group.find(params[:id])
    @forum = @group.forum
    @topics = Topic.find_recently_active(@forum, params[:page]) 
    @contacts = contacts_to_invite
    if Membership.exists?(current_person,@group)
      @add_membership_display = 'hide'
      @membership_display = ''
    else
      @add_membership_display = ''
      @membership_display = 'hide'
    end
    group_redirect_if_not_public 
  end

  def new
    @group = Group.new

    respond_to do |format|
      format.html
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])
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
    @group = Group.find(params[:id])

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
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      flash[:success] = t('success_group_deleted')
      format.html { redirect_to(groups_path) }
    end
  end
  
  def invite
    @group = Group.find(params[:id])
    @contacts = contacts_to_invite

    respond_to do |format|
      if current_person.own_groups.include?(@group) and @group.hidden?
        if @contacts.length == 0
          flash[:error] = t('error_no_contacts')
          format.html { redirect_to(group_path(@group)) }
        end
        format.html
      else
        format.html { redirect_to(group_path(@group)) }
      end
    end
  end
  
  def invite_them
    @group = Group.find(params[:id])
    invitations = params[:checkbox].collect{|x| x if  x[1]=="1" }.compact
    invitations.each do |invitation|
      if Membership.find_all_by_group_id(@group, :conditions => ['person_id = ?',invitation[0].to_i]).empty?
        Membership.invite(Person.find(invitation[0].to_i),@group)
      end
    end
    respond_to do |format|
      flash[:notice] = t('notice_invite_contacts') + " '#{@group.name}'"
      format.html { redirect_to(group_path(@group)) }
    end
  end
  
  def members
    @group = Group.find(params[:id])
    @members = @group.people.paginate(:page => params[:page],
                                          :per_page => RASTER_PER_PAGE)
    @pending = @group.pending_request.paginate(:page => params[:page],
                                          :per_page => RASTER_PER_PAGE)
    group_redirect_if_not_public
  end

  def photos
    @group = Group.find(params[:id])
    @photos = @group.photos
    respond_to do |format|
      format.html
    end
  end
  
  def new_photo
    @photo = Photo.new

    respond_to do |format|
      format.html
    end
  end
  
  def save_photo
    group = Group.find(params[:id])
    if params[:photo].nil?
      # This is mainly to prevent exceptions on iPhones.
      flash[:error] = t('error_browser_upload_fail')
      redirect_to(edit_group_path(group)) and return
    end
    if params[:commit] == "Cancel"
      flash[:notice] = t('notice_upload_canceled')
      redirect_to(edit_group_path(group)) and return
    end
    
    group_data = { :group => group,
                    :primary => group.photos.empty? }
    @photo = Photo.new(params[:photo].merge(group_data))
    
    respond_to do |format|
      if @photo.save
        flash[:success] = t('success_photo_uploaded')
        if group.owner == current_person
          format.html { redirect_to(edit_group_path(group)) }
        else
          format.html { redirect_to(group_path(group)) }
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
  
  def contacts_to_invite
    current_person.contacts - 
      Membership.find_all_by_group_id(current_person.own_hidden_groups).collect{|x| x.person}
  end
  
  def group_owner
    redirect_to home_url unless current_person == Group.find(params[:id]).owner
  end
  
  def group_redirect_if_not_public
    respond_to do |format|
      if @group.is_viewable?(current_person)
        format.html
        format.xml { render :xml => @group.to_xml(:methods => [:icon,:thumbnail], :only => [:id,:name,:description,:mode,:person_id,:created_at,:updated_at,:unit,:icon,:thumbnail]) }
        format.js
      else
        format.html { redirect_to(groups_path) }
        format.xml { render :nothing => true, :status => :unauthorized }
        format.js { render :nothing => true, :status => :unauthorized }
      end
    end
  end
  
end
