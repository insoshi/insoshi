class GalleriesController < ApplicationController
  # before_filter :login_required

  def show
    @body = "galleries"
  end
  def index
    @body = "galleries"
    @person = Person.find(params[:person_id])
    @all = @person.galleries
    @galleries = @all.paginate(:page => params[:page])
  end
  
  def new
    @gallery = Gallery.new
  end
  
  def create
    @gallery = Gallery.new(params[:gallery].merge(:person => current_person))
     respond_to do |format|
        if @gallery.save
          flash[:success] = "Gallery successfully created"
          format.html { redirect_to(gallery_path(@gallery)) }
        else
          format.html { render :action => "new" }
        end
      end
  end
  
end
