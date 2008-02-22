class PhotosController < ApplicationController

  before_filter :login_required
  # before_filter :correct_user_required, :only => [ :edit, :update, :destroy ]
  # before_filter :cancellation, :only => [ :create ]


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

  def edit
    @photo = Photo.find(params[:id])
    @display_photo = @photo
    respond_to do |format|
      format.html
    end
  end

  def create
    person_data = { :person => current_person,
                    :primary => current_person.photos.empty? }
    @photo = Photo.new(params[:photo].merge(person_data))
  
    respond_to do |format|
      if @photo.save
        format.html { redirect_to(edit_person_path(current_person)) }
      else
        format.html { render :action => "new" }
      end
    end
  end


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

