class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :correct_user_required,
                :only => [ :edit, :update, :destroy, :set_primary, 
                           :set_avatar ]
  before_filter :correct_gallery_requried, :only => [:new, :create]
  
  def index
    redirect_to person_galleries_path(current_person)
  end
  
  def show
    @photo = Photo.find(params[:id])
  end

  
  def new
    @photo = Photo.new
    @gallery = Gallery.find(params[:gallery_id])
    respond_to do |format|
      format.html
    end
  end

  def edit
    @display_photo = @photo
    respond_to do |format|
      format.html
    end
  end

  def create
    if params[:photo].nil?
      # This is mainly to prevent exceptions on iPhones.
      flash[:error] = "Your browser doesn't appear to support file uploading"
      redirect_to gallery_path(Gallery.find(params[:gallery_id])) and return
    end

    photo_data = params[:photo].merge(:person => current_person)
    @photo = @gallery.photos.build(photo_data)

    respond_to do |format|
      if @photo.save
        flash[:success] = "Photo successfully uploaded"
        format.html { redirect_to @photo.gallery }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @photo = Photo.find(params[:id])
    
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        flash[:success] = "Photo successfully updated"
        format.html { redirect_to(gallery_path(@photo.gallery)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def destroy
    @gallery = @photo.gallery
    redirect_to person_galleries_path(current_person) and return if @photo.nil?
    @photo.destroy
    flash[:success] = "Photo deleted"
    respond_to do |format|
      format.html { redirect_to gallery_path(@gallery) }
    end
  end
  
  def set_primary
    @photo = Photo.find(params[:id])
    if @photo.nil? or @photo.primary?
      redirect_to person_galleries_path(current_person) and return
    end
    # This should only have one entry, but be paranoid.
    @old_primary = @photo.gallery.photos.select(&:primary?)
    respond_to do |format|
      if @photo.update_attributes(:primary => true)
        @old_primary.each { |p| p.update_attributes!(:primary => false) }
        format.html { redirect_to(person_galleries_path(current_person)) }
        flash[:success] = "Gallery thumbnail set"
      else    
        format.html do
          flash[:error] = "Invalid image!"
          redirect_to home_url
        end
      end
    end
  end
  
  def set_avatar
    @photo = Photo.find(params[:id])
    if @photo.nil? or @photo.avatar?
      redirect_to current_person and return
    end
    # This should only have one entry, but be paranoid.
    @old_primary = current_person.photos.select(&:avatar?)
  
    respond_to do |format|
      if @photo.update_attributes!(:avatar => true)
        @old_primary.each { |p| p.update_attributes!(:avatar => false) }
        flash[:success] = "Profile photo set"
        format.html { redirect_to current_person }
      else    
        format.html do
          flash[:error] = "Invalid image!"
          redirect_to home_url
        end
      end
    end
  end
  
  private
  
    def correct_user_required
      @photo = Photo.find(params[:id])
      if @photo.nil?
        redirect_to home_url
      elsif !current_person?(@photo.person)
        redirect_to home_url
      end
    end
    
    def correct_gallery_requried
      if params[:gallery_id].nil?
        flash[:error] = "You cannot add photo without specifying gallery"
        redirect_to home_path
      else
        @gallery = Gallery.find(params[:gallery_id])
        if @gallery.person != current_person
          flash[:error] = "You cannot add photos to this gallery"
          redirect_to gallery_path(@gallery)
        end
      end
    end
end

