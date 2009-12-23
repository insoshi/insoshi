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

  def show
    @group = Group.find(params[:id])
    @forum = @group.forum
    @topics = Topic.find_recently_active(@forum, params[:page]) 
    @contacts = contacts_to_invite
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
        flash[:notice] = 'Group was successfully created.'
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
        flash[:notice] = 'Group was successfully updated.'
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
      flash[:notice] = 'Group was successfully deleted.'
      format.html { redirect_to(groups_path) }
    end
  end
  
  def invite
    @group = Group.find(params[:id])
    @contacts = contacts_to_invite

    respond_to do |format|
      if current_person.own_groups.include?(@group) and @group.hidden?
        if @contacts.length == 0
          flash[:error] = "You have no contacts or you have invited all of them"
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
      flash[:notice] = "You have invite some of your contacts to '#{@group.name}'"
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
      flash[:error] = "Your browser doesn't appear to support file uploading"
      redirect_to(edit_group_path(group)) and return
    end
    if params[:commit] == "Cancel"
      flash[:notice] = "You have canceled the upload"
      redirect_to(edit_group_path(group)) and return
    end
    
    group_data = { :group => group,
                    :primary => group.photos.empty? }
    @photo = Photo.new(params[:photo].merge(group_data))
    
    respond_to do |format|
      if @photo.save
        flash[:success] = "Photo successfully uploaded"
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
    flash[:success] = "Photo deleted for group '#{@group.name}'"
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
      else
        format.html { redirect_to(groups_path) }
        format.xml { render :nothing => true, :status => :unauthorized }
      end
    end
  end
  
end
