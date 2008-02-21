class PhotosController < ApplicationController

  before_filter :login_required
  # before_filter :correct_user_required, :only => [ :edit, :update, :destroy ]
  # before_filter :cancellation, :only => [ :create ]


  def index
    @photos = current_person.photos
  
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # # GET /photos/new
  # # GET /photos/new.xml
  # def new
  #   @photo = Photo.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render :xml => @photo }
  #   end
  # end
  # 
  # # GET /photos/1/edit
  # def edit
  #   @photo = Photo.find_by_hashed_id(params[:id])
  #   @display_photo = @photo
  # end
  # 
  # # POST /photos
  # # POST /photos.xml
  # def create
  #   if params[:photo][:uploaded_data].blank?
  #     flash[:error] = "Please choose an image"
  #     redirect_to new_photo_url and return
  #   end
  #   
  #   @photo = Photo.new(params[:photo].merge(
  #                       { :person => current_person,
  #                         :primary => current_person.photos.empty? }))
  # 
  #   respond_to do |format|
  #     if @photo.save
  #       format.html { redirect_to(edit_person_path(current_person)) }
  #       format.xml  { render :xml => @photo, :status => :created, :location => @photo }
  #     else
  #       format.html { render :action => "new" }
  #       format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # PUTUT /photos/1
  # # PUT /photos/1.xml
  # def update
  #   @photo = Photo.find_by_hashed_id(params[:id])
  #   redirect_to edit_person_url(current_person) and return if @photo.nil?
  #   # This should only have one entry, but be paranoid.
  #   # Also, subtract out current photo in case some idiot puts to this
  #   # by hand.
  #   @old_primary = current_person.photos.select(&:primary?) - [@photo]
  # 
  #   respond_to do |format|
  #     if @photo.update_attributes(:primary => true)
  #       @old_primary.each { |p| p.update_attributes!(:primary => false) }
  #       format.html { redirect_to(edit_person_path(current_person)) }
  #       format.xml  { head :ok }
  #     else    
  #       format.html do
  #         flash[:error] = "Invalid image!"
  #         redirect_to home_url
  #       end
  #       format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end
  # 
  # # DELETE /photos/1
  # # DELETE /photos/1.xml
  # def destroy
  #   @photo = Photo.find_by_hashed_id(params[:id])
  #   redirect_to edit_person_url(current_person) and return if @photo.nil?
  #   if @photo.primary?
  #     first_non_primary = current_person.photos.reject(&:primary?).first
  #     unless first_non_primary.nil?
  #       first_non_primary.update_attributes!(:primary => true)
  #     end
  #   end
  #   @photo.destroy
  # 
  #   respond_to do |format|
  #     format.html { redirect_to edit_person_url(current_person) }
  #     format.xml  { head :ok }
  #   end
  # end
  # 
  # private
  # 
  #   def correct_user_required
  #     photo = Photo.find_by_hashed_id(params[:id])
  #     redirect_to edit_person_url(current_person) and return if photo.nil?
  #     unless photo.person == current_person
  #       redirect_to login_url
  #     end
  #   end
  # 
  #   def cancellation
  #     cancel = params[:commit] == "Cancel"
  #     redirect_to edit_person_url(current_person) if cancel
  #   end
end

