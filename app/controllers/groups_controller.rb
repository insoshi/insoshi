class GroupsController < ApplicationController
  before_filter :login_required
  before_filter :group_owner, :only => [:edit, :update, :destroy, 
    :new_photo, :save_photo, :delete_photo]
  
  def index
    @groups = Group.paginate(:page => params[:page],
                                          :per_page => RASTER_PER_PAGE)

    respond_to do |format|
      format.html
    end
  end

  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html
    end
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

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(group_path(@group)) }
      else
        format.html { render :action => "new" }
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
      format.html { redirect_to(groups_path()) }
    end
  end
  
  def join
    @group = Group.find(params[:id])
    current_person.groups << @group
    respond_to do |format|
      flash[:notice] = 'Joined to group.'
      format.html { redirect_to(group_path(@group)) }
    end
  end
  
  def leave
    @group = Group.find(params[:id])
    if current_person.groups.include?(@group)
      flash[:notice] = 'You have left the group.'
      current_person.groups.delete(@group)
    end
    respond_to do |format|
      format.html { redirect_to(group_path(@group)) }
    end
  end
  
  def members
    @group = Group.find(params[:id])
    @members = @group.people.paginate(:page => params[:page],
                                          :per_page => RASTER_PER_PAGE)
    
    respond_to do |format|
      format.html
    end
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
  
  def group_owner
    redirect_to home_url unless current_person == Group.find(params[:id]).owner
  end
  
end
