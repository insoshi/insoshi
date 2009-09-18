class PhotosController < ApplicationController

  before_filter :login_required
  before_filter :correct_user_required, :only => [ :edit, :update, :destroy ]
  
  def index
    @photos = current_person.photos
  
    respond_to do |format|
      format.html
    end
  end

  def new
    @photo = Photo.new

    respond_to do |format|
      format.html
    end
  end
  
  def new
    @photo = Photo.new

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
      redirect_to edit_person_url(current_person) and return
    end
    if params[:commit] == "Cancel"
      redirect_to edit_person_url(current_person) and return
    end
    person_data = { :person => current_person,
                    :primary => current_person.photos.empty? }
    # raise params.inspect
    @photo = Photo.new(params[:photo].merge(person_data))
  
    respond_to do |format|
      if @photo.save
        flash[:success] = "Photo successfully uploaded"
        format.html { redirect_to(edit_person_path(current_person)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # Mark a photo as primary.
  # This marks the other photos as non-primary as a side-effect.
  def update
    if @photo.nil? or @photo.primary?
      redirect_to edit_person_url(current_person) and return
    end
    # This should only have one entry, but be paranoid.
    @old_primary = current_person.photos.select(&:primary?)
  
    respond_to do |format|
      if @photo.update_attributes(:primary => true)
        @old_primary.each { |p| p.update_attributes!(:primary => false) }
        format.html { redirect_to(edit_person_path(current_person)) }
      else    
        format.html do
          flash[:error] = "Invalid image!"
          redirect_to home_url
        end
      end
    end
  end

  def destroy
    redirect_to edit_person_url(current_person) and return if @photo.nil?
    if @photo.primary?
      first_non_primary = current_person.photos.reject(&:primary?).first
      unless first_non_primary.nil?
        first_non_primary.update_attributes!(:primary => true)
      end
    end
    @photo.destroy
    flash[:success] = "Photo deleted"
    respond_to do |format|
      format.html { redirect_to edit_person_url(current_person) }
    end
  end
  
  private
  
    def correct_user_required
      @photo = Photo.find(params[:id])
      if @photo.nil?
        redirect_to edit_person_url(current_person)
      elsif @photo.person != current_person
        redirect_to home_url
      end
    end
end

