class GalleriesController < ApplicationController
  before_filter :login_required
  before_filter :correct_user_required, :only => [ :edit, :update, :destroy ]
  
  def show
    @body = "galleries"
    @gallery = Gallery.find(params[:id])
    @photos = @gallery.photos.paginate :page => params[:page] 
  end
  
  def index
    @body = "galleries"
    @person = Person.find(params[:person_id])
    @galleries = @person.galleries.paginate :page => params[:page]
  end
  
  def new
    @gallery = Gallery.new
  end
  
  def create
    @gallery = current_person.galleries.build(params[:gallery])
    respond_to do |format|
      if @gallery.save
        flash[:success] = "Gallery successfully created"
        format.html { redirect_to gallery_path(@gallery) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @gallery = Gallery.find(params[:id])
  end
  
  def update
    @gallery = Gallery.find(params[:id])
    respond_to do |format|
      if @gallery.update_attributes(params[:gallery])
        flash[:success] = "Gallery successfully updated"
        format.html { redirect_to gallery_path(@gallery) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def destroy
    if current_person.galleries.count == 1
      flash[:error] = "You can't delete the final gallery"
    elsif Gallery.find(params[:id]).destroy
      flash[:success] = "Gallery successfully deleted"
    else
      flash[:error] = "Gallery could not be deleted"
    end

    respond_to do |format|
      format.html { redirect_to person_galleries_path(current_person) }
    end

  end
 
  private
  
    def correct_user_required
      @gallery = Gallery.find(params[:id])
      if @gallery.nil?
        flash[:error] = "No gallery found"
        redirect_to person_galleries_path(current_person)
      elsif @gallery.person != current_person
        flash[:error] = "You are not the owner of this gallery"
        redirect_to person_galleries_path(@gallery.person)
      end
    end
end
